import 'package:serverpod/protocol.dart'
    show FutureCallEntry, IntervalFutureCallScheduling;
import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/business/data_fetcher_scheduling.dart';
import 'package:starguide_server/src/business/data_source.dart';
import 'package:starguide_server/src/generated/protocol.dart'
    show RAGDocumentType;
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

class _FakeDataSource implements DataSource {
  _FakeDataSource(this.name);

  @override
  final String name;

  @override
  String get domain => 'Test';

  @override
  RAGDocumentType get documentType => RAGDocumentType.documentation;

  @override
  String get description => 'Fake source';

  @override
  Stream<RawRAGDocument> fetch(Session session, DataFetcher fetcher) =>
      const Stream.empty();
}

void main() {
  withServerpod(
    'Given configured data sources',
    // Only verify what gets scheduled; never run the fetches in tests.
    configOverride: (config) =>
        config.copyWith(futureCallExecutionEnabled: false),
    rollbackDatabase: RollbackDatabase.disabled,
    (sessionBuilder, endpoints) {
      final dataSourceNames = ['source-a', 'source-b'];

      setUpAll(() {
        DataFetcher.configure(
          dataSourceNames.map(_FakeDataSource.new).toList(),
        );
      });

      Future<List<FutureCallEntry>> scheduledEntries() async {
        final session = sessionBuilder.build();
        return FutureCallEntry.db.find(
          session,
          where: (t) => t.identifier.equals(dataFetcherIdentifier),
        );
      }

      test(
        'when scheduling data fetching then one recurring call per data '
        'source plus a clean up call are scheduled to start right away',
        () async {
          await scheduleDataFetching(Serverpod.instance);

          final entries = await scheduledEntries();
          expect(entries, hasLength(dataSourceNames.length + 1));

          final now = DateTime.now().toUtc();
          for (final entry in entries) {
            expect(
              entry.scheduling,
              isA<IntervalFutureCallScheduling>().having(
                (s) => s.interval,
                'interval',
                DataFetcher.instance.cacheDuration,
              ),
            );
            expect(entry.time.isBefore(now), isTrue);
          }

          final names = entries.map((e) => e.name).toList();
          expect(
            names.where((n) => n == 'DataFetcherFetchDataSourceFutureCall'),
            hasLength(dataSourceNames.length),
          );
          expect(names, contains('DataFetcherCleanUpFutureCall'));
        },
      );

      test('when scheduling data fetching again then the previous schedule is '
          'replaced instead of duplicated', () async {
        await scheduleDataFetching(Serverpod.instance);
        await scheduleDataFetching(Serverpod.instance);

        final entries = await scheduledEntries();
        expect(entries, hasLength(dataSourceNames.length + 1));
      });
    },
  );
}
