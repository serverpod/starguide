import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/business/data_fetcher_future_call.dart';
import 'package:starguide_server/src/generated/future_calls.dart';

/// Identifier shared by the recurring future calls that keep the data sources
/// up to date.
const dataFetcherIdentifier = 'data-fetcher';

/// Task name used for retries of [DataFetcherFutureCall.cleanUp].
const cleanUpRetryName = 'cleanUp';

/// Identifier of the one-off retry that is scheduled when the task [name]
/// (a data source name or [cleanUpRetryName]) fails.
String dataFetcherRetryIdentifier(String name) =>
    '$dataFetcherIdentifier-retry:$name';

/// Schedules the recurring future calls that fetch every configured data
/// source and clean up stale documents once per [DataFetcher.cacheDuration].
///
/// The first run happens right away. Any previously scheduled data fetcher
/// calls are cancelled first, so restarting the server does not accumulate
/// duplicate schedules and changes to the data sources take effect.
///
/// Must be called after the server has started, as future calls cannot be
/// scheduled before that.
Future<void> scheduleDataFetching(Serverpod pod) async {
  final dataFetcher = DataFetcher.instance;
  final futureCalls = pod.futureCalls;

  await futureCalls.cancel(dataFetcherIdentifier);
  await futureCalls.cancel(dataFetcherRetryIdentifier(cleanUpRetryName));
  for (final dataSource in dataFetcher.dataSources) {
    await futureCalls.cancel(dataFetcherRetryIdentifier(dataSource.name));
  }

  // A start time in the past makes the first run happen at the next scan.
  final start = DateTime.now().toUtc();

  for (final dataSource in dataFetcher.dataSources) {
    await futureCalls
        .callRecurring(identifier: dataFetcherIdentifier)
        .every(dataFetcher.cacheDuration, start: start)
        .dataFetcher
        .fetchDataSource(dataSource.name);
  }

  await futureCalls
      .callRecurring(identifier: dataFetcherIdentifier)
      .every(dataFetcher.cacheDuration, start: start)
      .dataFetcher
      .cleanUp();
}
