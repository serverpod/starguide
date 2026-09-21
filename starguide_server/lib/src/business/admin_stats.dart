import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/business/data_fetcher_scheduling.dart';
import 'package:starguide_server/src/generated/protocol.dart';

/// Computes the statistics shown in the admin interface.
class AdminStats {
  /// Number of days of daily statistics included in the overview.
  static const overviewDays = 30;

  /// Days this old or older are not expected to change any more, so their
  /// cached statistics are final. More recent days are recomputed on every
  /// request, as votes can be cast a while after a session is created.
  static const _finalizedAfter = Duration(days: 2);

  /// Names of the generated future calls that fetch data and clean up. They
  /// are looked up in the future call table to find the next scheduled runs.
  static const _fetchFutureCallName = 'DataFetcherFetchDataSourceFutureCall';
  static const _cleanUpFutureCallName = 'DataFetcherCleanUpFutureCall';

  /// A running future call is claimed by its server, which refreshes the
  /// claim's heartbeat every minute. Claims older than this are stale, e.g.
  /// left behind by a crashed server, and the call is not considered running.
  static const _staleClaimAge = Duration(minutes: 3);

  /// Builds the overview from the current state of the database.
  static Future<AdminOverview> overview(Session session) async {
    final dataFetcher = DataFetcher.instance;

    final results = await Future.wait([
      _sourceStatuses(session, dataFetcher),
      ChatSession.db.count(session),
      ChatMessage.db.count(session),
      _voteStats(session, Duration(days: 7)),
      _voteStats(session, Duration(days: 30)),
      dailyStats(session, days: overviewDays),
      _nextFutureCallTime(session, name: _cleanUpFutureCallName),
    ]);

    final sources = results[0] as List<AdminSourceStatus>;
    final fetchTimes = sources
        .map((source) => source.lastFetchTime)
        .nonNulls
        .toList();
    final oldestFetchTimes = sources
        .map((source) => source.oldestFetchTime)
        .nonNulls
        .toList();

    return AdminOverview(
      computedAt: DateTime.now().toUtc(),
      documentCount: sources.fold(0, (sum, s) => sum + s.documentCount),
      lastFetchTime: fetchTimes.isEmpty
          ? null
          : fetchTimes.reduce((a, b) => a.isAfter(b) ? a : b),
      oldestFetchTime: oldestFetchTimes.isEmpty
          ? null
          : oldestFetchTimes.reduce((a, b) => a.isBefore(b) ? a : b),
      nextCleanUpTime: results[6] as DateTime?,
      fetchInterval: dataFetcher.cacheDuration,
      removeOldDataAfter: dataFetcher.removeOldDataAfter,
      sources: sources,
      totalSessionCount: results[1] as int,
      totalMessageCount: results[2] as int,
      lastWeek: results[3] as VoteStats,
      lastMonth: results[4] as VoteStats,
      dailyStats: results[5] as List<DailyStats>,
    );
  }

  /// Returns the state of every configured data source, including documents
  /// in the database that no configured source produces any more.
  static Future<List<AdminSourceStatus>> _sourceStatuses(
    Session session,
    DataFetcher dataFetcher,
  ) async {
    // Counts and fetch times grouped by the domain and type that identify a
    // data source's documents.
    final rows = await session.db.unsafeQuery('''
      SELECT domain, type, COUNT(*)::int, MAX("fetchTime"), MIN("fetchTime")
      FROM rag_document
      GROUP BY domain, type
    ''');
    final counts = <(String, RAGDocumentType), DatabaseResultRow>{
      for (final row in rows)
        (row[0] as String, RAGDocumentType.values.byName(row[1] as String)):
            row,
    };

    // Scheduled fetches, running fetches and pending retries, keyed by data
    // source name.
    final nextFetchTimes = <String, DateTime>{};
    final runningSince = <String, DateTime>{};
    final retryTimes = <String, DateTime>{};
    for (final call in await _scheduledCalls(session, _fetchFutureCallName)) {
      if (call.serializedObject == null) continue;
      final sourceName = _fetchDataSourceName(call.serializedObject!);
      if (call.identifier == dataFetcherIdentifier) {
        if (call.isRunning) {
          runningSince[sourceName] = call.time;
        } else {
          nextFetchTimes[sourceName] = _earliest(
            nextFetchTimes[sourceName],
            call.time,
          );
        }
      } else if (call.identifier == dataFetcherRetryIdentifier(sourceName)) {
        if (call.isRunning) {
          runningSince[sourceName] = call.time;
        } else {
          retryTimes[sourceName] = call.time;
        }
      }
    }

    final statuses = <AdminSourceStatus>[];
    for (final dataSource in dataFetcher.dataSources) {
      final key = (dataSource.domain, dataSource.documentType);
      final row = counts.remove(key);
      statuses.add(
        AdminSourceStatus(
          name: dataSource.name,
          domain: dataSource.domain,
          type: dataSource.documentType,
          documentCount: row == null ? 0 : row[2] as int,
          lastFetchTime: (row?[3] as DateTime?)?.toUtc(),
          oldestFetchTime: (row?[4] as DateTime?)?.toUtc(),
          nextFetchTime: nextFetchTimes[dataSource.name],
          runningSince: runningSince[dataSource.name],
          retryTime: retryTimes[dataSource.name],
        ),
      );
    }

    // Documents left behind by sources that are no longer configured.
    for (final entry in counts.entries) {
      final row = entry.value;
      statuses.add(
        AdminSourceStatus(
          name: 'Unconfigured',
          domain: entry.key.$1,
          type: entry.key.$2,
          documentCount: row[2] as int,
          lastFetchTime: (row[3] as DateTime?)?.toUtc(),
          oldestFetchTime: (row[4] as DateTime?)?.toUtc(),
        ),
      );
    }

    return statuses;
  }

  /// Extracts the data source name from the serialized argument of a fetch
  /// future call, which is the JSON of the generated
  /// `DataFetcherFutureCallFetchDataSourceModel`.
  static String _fetchDataSourceName(String serializedObject) {
    final json = jsonDecode(serializedObject) as Map<String, dynamic>;
    return json['name'] as String;
  }

  /// The scheduled future calls with [name], including whether each one is
  /// currently running. A recurring call's entry stays in the table while it
  /// runs, with its next occurrence scheduled alongside it, so the running
  /// entries must be told apart from the upcoming ones.
  static Future<List<_ScheduledCall>> _scheduledCalls(
    Session session,
    String name,
  ) async {
    final rows = await session.db.unsafeQuery('''
      SELECT f.identifier, f."serializedObject", f.time, c."lastHeartbeatTime"
      FROM serverpod_future_call f
      LEFT JOIN serverpod_future_call_claim c ON c."futureCallId" = f.id
      WHERE f.name = @name
      ''', parameters: QueryParameters.named({'name': name}));
    final staleBefore = DateTime.now().toUtc().subtract(_staleClaimAge);
    return [
      for (final row in rows)
        _ScheduledCall(
          identifier: row[0] as String?,
          serializedObject: row[1] as String?,
          time: (row[2] as DateTime).toUtc(),
          isRunning:
              row[3] != null &&
              (row[3] as DateTime).toUtc().isAfter(staleBefore),
        ),
    ];
  }

  /// When the next future call with [name] is scheduled to run, not counting
  /// calls that are currently running.
  static Future<DateTime?> _nextFutureCallTime(
    Session session, {
    required String name,
  }) async {
    DateTime? next;
    for (final call in await _scheduledCalls(session, name)) {
      if (!call.isRunning) next = _earliest(next, call.time);
    }
    return next;
  }

  static DateTime _earliest(DateTime? a, DateTime b) =>
      a == null || b.isBefore(a) ? b : a;

  /// Vote counts for the sessions created during the past [period].
  static Future<VoteStats> _voteStats(Session session, Duration period) async {
    final rows = await session.db.unsafeQuery(
      '''
      SELECT
        COUNT(*)::int,
        COUNT(*) FILTER (WHERE "goodAnswer" = TRUE)::int,
        COUNT(*) FILTER (WHERE "goodAnswer" = FALSE)::int,
        COUNT(*) FILTER (WHERE "answerOutcome" = @answered)::int,
        COUNT(*) FILTER (WHERE "answerOutcome" = @notAnswered)::int,
        COUNT(*) FILTER (WHERE "answerOutcome" = @unsure)::int
      FROM chat_session
      WHERE "createdAt" >= @from
      ''',
      parameters: QueryParameters.named({
        'from': DateTime.now().toUtc().subtract(period),
        'answered': AnswerOutcome.answered.name,
        'notAnswered': AnswerOutcome.notAnswered.name,
        'unsure': AnswerOutcome.unsure.name,
      }),
    );
    final row = rows.first;
    return VoteStats(
      sessionCount: row[0] as int,
      goodAnswerCount: row[1] as int,
      poorAnswerCount: row[2] as int,
      answeredCount: row[3] as int,
      notAnsweredCount: row[4] as int,
      unsureCount: row[5] as int,
    );
  }

  /// Returns statistics for each of the past [days] days, oldest first,
  /// with today as the last entry. Days are in UTC.
  ///
  /// Statistics for days that can no longer change are cached in the
  /// `daily_stats` table, so only the most recent days are aggregated from
  /// the chat sessions.
  static Future<List<DailyStats>> dailyStats(
    Session session, {
    required int days,
  }) async {
    final now = DateTime.now().toUtc();
    final today = DateTime.utc(now.year, now.month, now.day);
    final firstDay = today.subtract(Duration(days: days - 1));
    final finalizedBefore = today.subtract(_finalizedAfter);

    final cached = await DailyStats.db.find(
      session,
      where: (t) => t.day >= firstDay,
    );
    final statsByDay = {for (final stats in cached) stats.day.toUtc(): stats};

    final allDays = [
      for (var i = 0; i < days; i++) firstDay.add(Duration(days: i)),
    ];
    final daysToCompute = [
      for (final day in allDays)
        if (!statsByDay.containsKey(day) || !day.isBefore(finalizedBefore)) day,
    ];

    if (daysToCompute.isNotEmpty) {
      final computed = await _computeDailyStats(
        session,
        from: daysToCompute.first,
      );
      for (final day in daysToCompute) {
        final stats =
            computed[day] ??
            DailyStats(
              day: day,
              sessionCount: 0,
              goodAnswerCount: 0,
              poorAnswerCount: 0,
              answeredCount: 0,
              notAnsweredCount: 0,
              unsureCount: 0,
            );
        statsByDay[day] = await _storeDailyStats(
          session,
          stats,
          existing: statsByDay[day],
        );
      }
    }

    return [
      for (final day in allDays)
        statsByDay[day] ??
            DailyStats(
              day: day,
              sessionCount: 0,
              goodAnswerCount: 0,
              poorAnswerCount: 0,
              answeredCount: 0,
              notAnsweredCount: 0,
              unsureCount: 0,
            ),
    ];
  }

  /// Aggregates the chat sessions created since [from] per day.
  static Future<Map<DateTime, DailyStats>> _computeDailyStats(
    Session session, {
    required DateTime from,
  }) async {
    final rows = await session.db.unsafeQuery(
      '''
      SELECT
        date_trunc('day', "createdAt") AS day,
        COUNT(*)::int,
        COUNT(*) FILTER (WHERE "goodAnswer" = TRUE)::int,
        COUNT(*) FILTER (WHERE "goodAnswer" = FALSE)::int,
        COUNT(*) FILTER (WHERE "answerOutcome" = @answered)::int,
        COUNT(*) FILTER (WHERE "answerOutcome" = @notAnswered)::int,
        COUNT(*) FILTER (WHERE "answerOutcome" = @unsure)::int
      FROM chat_session
      WHERE "createdAt" >= @from
      GROUP BY day
      ''',
      parameters: QueryParameters.named({
        'from': from,
        'answered': AnswerOutcome.answered.name,
        'notAnswered': AnswerOutcome.notAnswered.name,
        'unsure': AnswerOutcome.unsure.name,
      }),
    );
    return {
      for (final row in rows)
        (row[0] as DateTime).toUtc(): DailyStats(
          day: (row[0] as DateTime).toUtc(),
          sessionCount: row[1] as int,
          goodAnswerCount: row[2] as int,
          poorAnswerCount: row[3] as int,
          answeredCount: row[4] as int,
          notAnsweredCount: row[5] as int,
          unsureCount: row[6] as int,
        ),
    };
  }

  /// Saves [stats] to the cache table, replacing [existing] if given. If
  /// saving fails, e.g. because a concurrent request stored the same day,
  /// the computed statistics are still returned.
  static Future<DailyStats> _storeDailyStats(
    Session session,
    DailyStats stats, {
    DailyStats? existing,
  }) async {
    try {
      if (existing == null) {
        return await DailyStats.db.insertRow(session, stats);
      }
      if (existing.sessionCount == stats.sessionCount &&
          existing.goodAnswerCount == stats.goodAnswerCount &&
          existing.poorAnswerCount == stats.poorAnswerCount &&
          existing.answeredCount == stats.answeredCount &&
          existing.notAnsweredCount == stats.notAnsweredCount &&
          existing.unsureCount == stats.unsureCount) {
        return existing;
      }
      return await DailyStats.db.updateRow(
        session,
        stats.copyWith(id: existing.id),
      );
    } catch (e) {
      session.log(
        'Failed to cache daily stats for ${stats.day}: $e',
        level: LogLevel.warning,
      );
      return stats;
    }
  }
}

/// A row of the future call table, joined with its claim if it is running.
class _ScheduledCall {
  const _ScheduledCall({
    required this.identifier,
    required this.serializedObject,
    required this.time,
    required this.isRunning,
  });

  final String? identifier;
  final String? serializedObject;

  /// When the call was, or is, due to run.
  final DateTime time;

  /// Whether a server holds a live claim on the call, i.e. is running it.
  final bool isRunning;
}
