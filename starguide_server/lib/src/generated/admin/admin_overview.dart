/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;
import 'package:starguide_server/src/generated/protocol.dart' as _ih7yasqo;
import '../admin/admin_source_status.dart' as _i4gyflh3;
import '../admin/daily_stats.dart' as _ibr24dhf;
import '../admin/vote_stats.dart' as _ipqd24x9;

/// Statistics shown on the admin overview.
abstract class AdminOverview
    implements _is.SerializableModel, _is.ProtocolSerialization {
  AdminOverview._({
    required this.computedAt,
    required this.documentCount,
    this.lastFetchTime,
    this.oldestFetchTime,
    this.nextCleanUpTime,
    required this.fetchInterval,
    required this.removeOldDataAfter,
    required this.sources,
    required this.totalSessionCount,
    required this.totalMessageCount,
    required this.lastWeek,
    required this.lastMonth,
    required this.dailyStats,
  });

  factory AdminOverview({
    required DateTime computedAt,
    required int documentCount,
    DateTime? lastFetchTime,
    DateTime? oldestFetchTime,
    DateTime? nextCleanUpTime,
    required Duration fetchInterval,
    required Duration removeOldDataAfter,
    required List<_i4gyflh3.AdminSourceStatus> sources,
    required int totalSessionCount,
    required int totalMessageCount,
    required _ipqd24x9.VoteStats lastWeek,
    required _ipqd24x9.VoteStats lastMonth,
    required List<_ibr24dhf.DailyStats> dailyStats,
  }) = _AdminOverviewImpl;

  factory AdminOverview.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminOverview(
      computedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['computedAt'],
      ),
      documentCount: jsonSerialization['documentCount'] as int,
      lastFetchTime: jsonSerialization['lastFetchTime'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastFetchTime'],
            ),
      oldestFetchTime: jsonSerialization['oldestFetchTime'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['oldestFetchTime'],
            ),
      nextCleanUpTime: jsonSerialization['nextCleanUpTime'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['nextCleanUpTime'],
            ),
      fetchInterval: _is.DurationJsonExtension.fromJson(
        jsonSerialization['fetchInterval'],
      ),
      removeOldDataAfter: _is.DurationJsonExtension.fromJson(
        jsonSerialization['removeOldDataAfter'],
      ),
      sources: _ih7yasqo.Protocol()
          .deserialize<List<_i4gyflh3.AdminSourceStatus>>(
            jsonSerialization['sources'],
          ),
      totalSessionCount: jsonSerialization['totalSessionCount'] as int,
      totalMessageCount: jsonSerialization['totalMessageCount'] as int,
      lastWeek: _ih7yasqo.Protocol().deserialize<_ipqd24x9.VoteStats>(
        jsonSerialization['lastWeek'],
      ),
      lastMonth: _ih7yasqo.Protocol().deserialize<_ipqd24x9.VoteStats>(
        jsonSerialization['lastMonth'],
      ),
      dailyStats: _ih7yasqo.Protocol().deserialize<List<_ibr24dhf.DailyStats>>(
        jsonSerialization['dailyStats'],
      ),
    );
  }

  DateTime computedAt;

  int documentCount;

  DateTime? lastFetchTime;

  DateTime? oldestFetchTime;

  /// When the next clean up of stale documents is scheduled.
  DateTime? nextCleanUpTime;

  /// How often each data source is fetched.
  Duration fetchInterval;

  /// Documents that have not been re-fetched for this long are removed.
  Duration removeOldDataAfter;

  List<_i4gyflh3.AdminSourceStatus> sources;

  int totalSessionCount;

  int totalMessageCount;

  /// Sessions created during the past 7 days.
  _ipqd24x9.VoteStats lastWeek;

  /// Sessions created during the past 30 days.
  _ipqd24x9.VoteStats lastMonth;

  /// One entry per day, oldest first.
  List<_ibr24dhf.DailyStats> dailyStats;

  /// Returns a shallow copy of this [AdminOverview]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AdminOverview copyWith({
    DateTime? computedAt,
    int? documentCount,
    DateTime? lastFetchTime,
    DateTime? oldestFetchTime,
    DateTime? nextCleanUpTime,
    Duration? fetchInterval,
    Duration? removeOldDataAfter,
    List<_i4gyflh3.AdminSourceStatus>? sources,
    int? totalSessionCount,
    int? totalMessageCount,
    _ipqd24x9.VoteStats? lastWeek,
    _ipqd24x9.VoteStats? lastMonth,
    List<_ibr24dhf.DailyStats>? dailyStats,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminOverview',
      'computedAt': computedAt.toJson(),
      'documentCount': documentCount,
      if (lastFetchTime != null) 'lastFetchTime': lastFetchTime?.toJson(),
      if (oldestFetchTime != null) 'oldestFetchTime': oldestFetchTime?.toJson(),
      if (nextCleanUpTime != null) 'nextCleanUpTime': nextCleanUpTime?.toJson(),
      'fetchInterval': fetchInterval.toJson(),
      'removeOldDataAfter': removeOldDataAfter.toJson(),
      'sources': sources.toJson(valueToJson: (v) => v.toJson()),
      'totalSessionCount': totalSessionCount,
      'totalMessageCount': totalMessageCount,
      'lastWeek': lastWeek.toJson(),
      'lastMonth': lastMonth.toJson(),
      'dailyStats': dailyStats.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminOverview',
      'computedAt': computedAt.toJson(),
      'documentCount': documentCount,
      if (lastFetchTime != null) 'lastFetchTime': lastFetchTime?.toJson(),
      if (oldestFetchTime != null) 'oldestFetchTime': oldestFetchTime?.toJson(),
      if (nextCleanUpTime != null) 'nextCleanUpTime': nextCleanUpTime?.toJson(),
      'fetchInterval': fetchInterval.toJson(),
      'removeOldDataAfter': removeOldDataAfter.toJson(),
      'sources': sources.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'totalSessionCount': totalSessionCount,
      'totalMessageCount': totalMessageCount,
      'lastWeek': lastWeek.toJsonForProtocol(),
      'lastMonth': lastMonth.toJsonForProtocol(),
      'dailyStats': dailyStats.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminOverviewImpl extends AdminOverview {
  _AdminOverviewImpl({
    required DateTime computedAt,
    required int documentCount,
    DateTime? lastFetchTime,
    DateTime? oldestFetchTime,
    DateTime? nextCleanUpTime,
    required Duration fetchInterval,
    required Duration removeOldDataAfter,
    required List<_i4gyflh3.AdminSourceStatus> sources,
    required int totalSessionCount,
    required int totalMessageCount,
    required _ipqd24x9.VoteStats lastWeek,
    required _ipqd24x9.VoteStats lastMonth,
    required List<_ibr24dhf.DailyStats> dailyStats,
  }) : super._(
         computedAt: computedAt,
         documentCount: documentCount,
         lastFetchTime: lastFetchTime,
         oldestFetchTime: oldestFetchTime,
         nextCleanUpTime: nextCleanUpTime,
         fetchInterval: fetchInterval,
         removeOldDataAfter: removeOldDataAfter,
         sources: sources,
         totalSessionCount: totalSessionCount,
         totalMessageCount: totalMessageCount,
         lastWeek: lastWeek,
         lastMonth: lastMonth,
         dailyStats: dailyStats,
       );

  /// Returns a shallow copy of this [AdminOverview]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AdminOverview copyWith({
    DateTime? computedAt,
    int? documentCount,
    Object? lastFetchTime = _Undefined,
    Object? oldestFetchTime = _Undefined,
    Object? nextCleanUpTime = _Undefined,
    Duration? fetchInterval,
    Duration? removeOldDataAfter,
    List<_i4gyflh3.AdminSourceStatus>? sources,
    int? totalSessionCount,
    int? totalMessageCount,
    _ipqd24x9.VoteStats? lastWeek,
    _ipqd24x9.VoteStats? lastMonth,
    List<_ibr24dhf.DailyStats>? dailyStats,
  }) {
    return AdminOverview(
      computedAt: computedAt ?? this.computedAt,
      documentCount: documentCount ?? this.documentCount,
      lastFetchTime: lastFetchTime is DateTime?
          ? lastFetchTime
          : this.lastFetchTime,
      oldestFetchTime: oldestFetchTime is DateTime?
          ? oldestFetchTime
          : this.oldestFetchTime,
      nextCleanUpTime: nextCleanUpTime is DateTime?
          ? nextCleanUpTime
          : this.nextCleanUpTime,
      fetchInterval: fetchInterval ?? this.fetchInterval,
      removeOldDataAfter: removeOldDataAfter ?? this.removeOldDataAfter,
      sources: sources ?? this.sources.map((e0) => e0.copyWith()).toList(),
      totalSessionCount: totalSessionCount ?? this.totalSessionCount,
      totalMessageCount: totalMessageCount ?? this.totalMessageCount,
      lastWeek: lastWeek ?? this.lastWeek.copyWith(),
      lastMonth: lastMonth ?? this.lastMonth.copyWith(),
      dailyStats:
          dailyStats ?? this.dailyStats.map((e0) => e0.copyWith()).toList(),
    );
  }
}
