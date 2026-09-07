import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/generated/future_calls.dart';

import 'data_fetcher.dart';

class DataFetcherFutureCall extends FutureCall {
  Future<void> startFetching(Session session) async {
    final dataFetcher = DataFetcher.instance;
    session.log('Starting data fetcher.', level: LogLevel.debug);

    for (var dataSource in dataFetcher.dataSources) {
      await session.serverpod.futureCalls
          .callWithDelay(const Duration())
          .dataFetcher
          .fetchDataSource(dataSource.name);
    }

    await session.serverpod.futureCalls
        .callWithDelay(const Duration())
        .dataFetcher
        .cleanUp();
  }

  Future<void> fetchDataSource(Session session, String name) async {
    final dataFetcher = DataFetcher.instance;

    session.log('Fetching data from $name.', level: LogLevel.debug);

    bool success = false;

    final dataSource = dataFetcher.dataSources.firstWhere(
      (dataSource) => dataSource.name == name,
    );
    try {
      await dataFetcher.fetchDataSource(session, dataSource);
      success = true;
    } catch (e, stackTrace) {
      session.log(
        'Error fetching data from $dataSource: $e',
        exception: e,
        stackTrace: stackTrace,
      );
    }

    final delay = success
        ? dataFetcher.cacheDuration
        : DataFetcher.fetchRetryDelay;

    await session.serverpod.futureCalls
        .callWithDelay(delay)
        .dataFetcher
        .fetchDataSource(name);
  }

  Future<void> cleanUp(Session session) async {
    final dataFetcher = DataFetcher.instance;

    session.log('Cleaning up data.', level: LogLevel.debug);

    bool success = false;
    try {
      await dataFetcher.cleanUp(session);
      success = true;
    } catch (e, stackTrace) {
      session.log(
        'Error cleaning up data: $e',
        exception: e,
        stackTrace: stackTrace,
      );
    }

    final delay = success
        ? dataFetcher.cacheDuration
        : DataFetcher.fetchRetryDelay;

    await session.serverpod.futureCalls
        .callWithDelay(delay)
        .dataFetcher
        .cleanUp();
  }
}
