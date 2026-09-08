import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_fetcher_scheduling.dart';
import 'package:starguide_server/src/generated/future_calls.dart';

import 'data_fetcher.dart';

/// Future calls that keep the RAG documents up to date. They are scheduled as
/// recurring calls by [scheduleDataFetching].
class DataFetcherFutureCall extends FutureCall {
  Future<void> fetchDataSource(Session session, String name) async {
    final dataFetcher = DataFetcher.instance;

    session.log('Fetching data from $name.', level: LogLevel.debug);

    final dataSource = dataFetcher.dataSources.firstWhere(
      (dataSource) => dataSource.name == name,
    );
    try {
      await dataFetcher.fetchDataSource(session, dataSource);
    } catch (e, stackTrace) {
      session.log(
        'Error fetching data from $dataSource: $e',
        exception: e,
        stackTrace: stackTrace,
      );
      await _scheduleRetry(session, name);
    }
  }

  Future<void> cleanUp(Session session) async {
    final dataFetcher = DataFetcher.instance;

    session.log('Cleaning up data.', level: LogLevel.debug);

    try {
      await dataFetcher.cleanUp(session);
    } catch (e, stackTrace) {
      session.log(
        'Error cleaning up data: $e',
        exception: e,
        stackTrace: stackTrace,
      );
      await _scheduleRetry(session, cleanUpRetryName);
    }
  }

  /// Schedules a one-off retry after [DataFetcher.fetchRetryDelay]. The
  /// recurring schedule is unaffected. Any pending retry for the same task is
  /// cancelled first, so at most one retry is queued per task.
  Future<void> _scheduleRetry(Session session, String name) async {
    final identifier = dataFetcherRetryIdentifier(name);
    final futureCalls = session.serverpod.futureCalls;

    await futureCalls.cancel(identifier);

    final retry = futureCalls
        .callWithDelay(DataFetcher.fetchRetryDelay, identifier: identifier)
        .dataFetcher;

    if (name == cleanUpRetryName) {
      await retry.cleanUp();
    } else {
      await retry.fetchDataSource(name);
    }
  }
}
