import 'dart:convert';

import 'package:serverpod/protocol.dart'
    show FutureCallClaimEntry, FutureCallEntry;
import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_fetcher_scheduling.dart';
import 'package:starguide_server/src/business/admin_stats.dart';
import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/business/data_source.dart';
import 'package:starguide_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

class _FakeDataSource implements DataSource {
  _FakeDataSource(
    this.name, {
    required this.domain,
    required this.documentType,
  });

  @override
  final String name;

  @override
  final String domain;

  @override
  final RAGDocumentType documentType;

  @override
  Stream<RawRAGDocument> fetch(Session session, DataFetcher fetcher) =>
      const Stream.empty();
}

RAGDocument _document({
  required String title,
  required RAGDocumentType type,
  required String domain,
  required DateTime fetchTime,
}) {
  return RAGDocument(
    embedding: Vector(List<double>.filled(768, 0)),
    fetchTime: fetchTime,
    sourceUrl: Uri.parse('https://example.com/${title.replaceAll(' ', '-')}'),
    content: 'Content of $title',
    title: title,
    embeddingSummary: 'Embedding summary of $title',
    shortDescription: 'Description of $title',
    type: type,
    domain: domain,
  );
}

void main() {
  withServerpod(
    'Given the admin endpoint',
    configOverride: (config) =>
        config.copyWith(futureCallExecutionEnabled: false),
    (sessionBuilder, endpoints) {
      final admin = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          'admin-user',
          {Scope.admin},
        ),
      );
      final signedInUser = sessionBuilder.copyWith(
        authentication: AuthenticationOverride.authenticationInfo(
          'regular-user',
          {},
        ),
      );

      setUpAll(() {
        DataFetcher.configure([
          _FakeDataSource(
            'docs',
            domain: 'Serverpod',
            documentType: RAGDocumentType.documentation,
          ),
          _FakeDataSource(
            'discussions',
            domain: 'Serverpod',
            documentType: RAGDocumentType.discussion,
          ),
        ]);
      });

      test('when not signed in then calls are rejected', () async {
        await expectLater(
          endpoints.admin.getOverview(sessionBuilder),
          throwsA(isA<ServerpodUnauthenticatedException>()),
        );
      });

      test(
        'when signed in without the admin scope then calls are rejected',
        () async {
          await expectLater(
            endpoints.admin.getOverview(signedInUser),
            throwsA(isA<ServerpodInsufficientAccessException>()),
          );
        },
      );

      group('with documents and chat sessions in the database', () {
        final now = DateTime.now().toUtc();
        late int poorSessionId;

        setUp(() async {
          final session = sessionBuilder.build();

          await RAGDocument.db.insert(session, [
            _document(
              title: 'Getting started',
              type: RAGDocumentType.documentation,
              domain: 'Serverpod',
              fetchTime: now.subtract(Duration(hours: 1)),
            ),
            _document(
              title: 'Database basics',
              type: RAGDocumentType.documentation,
              domain: 'Serverpod',
              fetchTime: now.subtract(Duration(hours: 2)),
            ),
            _document(
              title: 'How do I deploy?',
              type: RAGDocumentType.discussion,
              domain: 'Serverpod',
              fetchTime: now.subtract(Duration(days: 1)),
            ),
            _document(
              title: 'Relic routing',
              type: RAGDocumentType.documentation,
              domain: 'Relic',
              fetchTime: now.subtract(Duration(days: 2)),
            ),
          ]);

          final poorSession = await ChatSession.db.insertRow(
            session,
            ChatSession(
              keyToken: 'poor',
              goodAnswer: false,
              createdAt: now.subtract(Duration(days: 1)),
            ),
          );
          poorSessionId = poorSession.id!;
          await ChatSession.db.insert(session, [
            ChatSession(keyToken: 'good', goodAnswer: true, createdAt: now),
            ChatSession(keyToken: 'unvoted', createdAt: now),
            ChatSession(
              keyToken: 'old-good',
              goodAnswer: true,
              createdAt: now.subtract(Duration(days: 10)),
            ),
          ]);
          await ChatMessage.db.insert(session, [
            ChatMessage(
              chatSessionId: poorSessionId,
              message: 'How do I run migrations?',
              type: ChatMessageType.user,
            ),
            ChatMessage(
              chatSessionId: poorSessionId,
              message: 'Run `serverpod create-migration`.',
              type: ChatMessageType.model,
            ),
            ChatMessage(
              chatSessionId: poorSessionId,
              message: 'That did not work.',
              type: ChatMessageType.user,
            ),
          ]);
        });

        test(
          'when getting the overview then it summarizes the database',
          () async {
            final overview = await endpoints.admin.getOverview(admin);

            expect(overview.documentCount, 4);
            expect(overview.totalSessionCount, 4);
            expect(overview.totalMessageCount, 3);

            expect(overview.lastWeek.sessionCount, 3);
            expect(overview.lastWeek.goodAnswerCount, 1);
            expect(overview.lastWeek.poorAnswerCount, 1);
            expect(overview.lastMonth.sessionCount, 4);
            expect(overview.lastMonth.goodAnswerCount, 2);

            expect(overview.dailyStats, hasLength(AdminStats.overviewDays));
            expect(overview.dailyStats.last.sessionCount, 2);
            expect(overview.dailyStats.last.goodAnswerCount, 1);
            final yesterday =
                overview.dailyStats[overview.dailyStats.length - 2];
            expect(yesterday.poorAnswerCount, 1);
            expect(
              overview.dailyStats.fold(0, (sum, s) => sum + s.sessionCount),
              4,
            );

            final sourcesByName = {for (final s in overview.sources) s.name: s};
            expect(sourcesByName['docs']!.documentCount, 2);
            expect(sourcesByName['discussions']!.documentCount, 1);
            // The Relic document belongs to no configured source.
            expect(sourcesByName['Unconfigured']!.documentCount, 1);
            expect(
              overview.lastFetchTime!
                  .difference(now.subtract(Duration(hours: 1)))
                  .abs(),
              lessThan(Duration(seconds: 1)),
            );
          },
        );

        test('when listing documents then filters and paging apply', () async {
          final all = await endpoints.admin.listDocuments(
            admin,
            page: 0,
            pageSize: 3,
          );
          expect(all.totalCount, 4);
          expect(all.documents, hasLength(3));
          // Most recently fetched first.
          expect(all.documents.first.title, 'Getting started');

          final secondPage = await endpoints.admin.listDocuments(
            admin,
            page: 1,
            pageSize: 3,
          );
          expect(secondPage.documents.map((d) => d.title), ['Relic routing']);

          final discussions = await endpoints.admin.listDocuments(
            admin,
            page: 0,
            pageSize: 10,
            type: RAGDocumentType.discussion,
          );
          expect(discussions.documents.map((d) => d.title), [
            'How do I deploy?',
          ]);

          final relic = await endpoints.admin.listDocuments(
            admin,
            page: 0,
            pageSize: 10,
            domain: 'Relic',
          );
          expect(relic.documents.map((d) => d.title), ['Relic routing']);

          final search = await endpoints.admin.listDocuments(
            admin,
            page: 0,
            pageSize: 10,
            search: 'database',
          );
          expect(search.documents.map((d) => d.title), ['Database basics']);

          final domains = await endpoints.admin.listDocumentDomains(admin);
          expect(domains, ['Relic', 'Serverpod']);
        });

        test('when getting a document then its content is included', () async {
          final page = await endpoints.admin.listDocuments(
            admin,
            page: 0,
            pageSize: 1,
            search: 'Relic',
          );
          final detail = await endpoints.admin.getDocument(
            admin,
            page.documents.single.id,
          );
          expect(detail.title, 'Relic routing');
          expect(detail.content, 'Content of Relic routing');
          expect(detail.embeddingSummary, 'Embedding summary of Relic routing');
        });

        test(
          'when listing chat sessions then poor answers are listed by default with their first question',
          () async {
            final poor = await endpoints.admin.listChatSessions(
              admin,
              page: 0,
              pageSize: 10,
              goodAnswer: false,
              votedOnly: false,
            );
            expect(poor.totalCount, 1);
            final summary = poor.sessions.single;
            expect(summary.id, poorSessionId);
            expect(summary.goodAnswer, false);
            expect(summary.messageCount, 3);
            expect(summary.firstQuestion, 'How do I run migrations?');

            final voted = await endpoints.admin.listChatSessions(
              admin,
              page: 0,
              pageSize: 10,
              goodAnswer: null,
              votedOnly: true,
            );
            expect(voted.totalCount, 3);

            final all = await endpoints.admin.listChatSessions(
              admin,
              page: 0,
              pageSize: 10,
              goodAnswer: null,
              votedOnly: false,
            );
            expect(all.totalCount, 4);
            // Newest first.
            expect(all.sessions.last.goodAnswer, true);
            expect(all.sessions.first.messageCount, 0);
          },
        );

        test(
          'when getting a chat session then the conversation is included',
          () async {
            final detail = await endpoints.admin.getChatSession(
              admin,
              poorSessionId,
            );
            expect(detail.goodAnswer, false);
            expect(detail.messages.map((m) => m.type), [
              ChatMessageType.user,
              ChatMessageType.model,
              ChatMessageType.user,
            ]);
          },
        );
      });

      group('with scheduled and running fetches', () {
        final now = DateTime.now().toUtc();

        setUp(() async {
          final session = sessionBuilder.build();
          String argument(String name) => jsonEncode({'name': name});
          const callName = 'DataFetcherFetchDataSourceFutureCall';

          // The docs fetch is running: its due entry is claimed with a live
          // heartbeat, and its next occurrence is already scheduled.
          final running = await FutureCallEntry.db.insertRow(
            session,
            FutureCallEntry(
              name: callName,
              time: now.subtract(Duration(minutes: 8)),
              serializedObject: argument('docs'),
              serverId: 'test',
              identifier: dataFetcherIdentifier,
            ),
          );
          await FutureCallClaimEntry.db.insertRow(
            session,
            FutureCallClaimEntry(
              futureCallId: running.id,
              lastHeartbeatTime: now.subtract(Duration(seconds: 30)),
            ),
          );
          await FutureCallEntry.db.insertRow(
            session,
            FutureCallEntry(
              name: callName,
              time: now.add(Duration(hours: 23)),
              serializedObject: argument('docs'),
              serverId: 'test',
              identifier: dataFetcherIdentifier,
            ),
          );

          // The discussions fetch is only scheduled.
          await FutureCallEntry.db.insertRow(
            session,
            FutureCallEntry(
              name: callName,
              time: now.add(Duration(hours: 1)),
              serializedObject: argument('discussions'),
              serverId: 'test',
              identifier: dataFetcherIdentifier,
            ),
          );
        });

        test(
          'when getting the overview then running fetches are told apart from scheduled ones',
          () async {
            final overview = await endpoints.admin.getOverview(admin);
            final sourcesByName = {for (final s in overview.sources) s.name: s};

            final docs = sourcesByName['docs']!;
            expect(docs.runningSince, isNotNull);
            expect(
              docs.runningSince!
                  .difference(now.subtract(Duration(minutes: 8)))
                  .abs(),
              lessThan(Duration(seconds: 1)),
            );
            expect(docs.nextFetchTime!.isAfter(now), isTrue);

            final discussions = sourcesByName['discussions']!;
            expect(discussions.runningSince, isNull);
            expect(discussions.nextFetchTime!.isAfter(now), isTrue);
          },
        );
      });

      group('daily stats cache', () {
        test(
          'when computing daily stats then past days are cached and recent days recomputed',
          () async {
            final session = sessionBuilder.build();
            final now = DateTime.now().toUtc();
            final today = DateTime.utc(now.year, now.month, now.day);
            final fiveDaysAgo = today.subtract(Duration(days: 5));

            await ChatSession.db.insertRow(
              session,
              ChatSession(
                keyToken: 'a',
                goodAnswer: true,
                createdAt: fiveDaysAgo.add(Duration(hours: 3)),
              ),
            );

            final first = await AdminStats.dailyStats(session, days: 7);
            expect(first, hasLength(7));
            expect(first.first.day, today.subtract(Duration(days: 6)));
            expect(first.last.day, today);
            expect(first[1].day, fiveDaysAgo);
            expect(first[1].sessionCount, 1);
            expect(first[1].goodAnswerCount, 1);

            final cached = await DailyStats.db.find(session);
            expect(cached, hasLength(7));

            // A session added to a finalized day is not picked up, as that
            // day is served from the cache. A session added today is.
            await ChatSession.db.insert(session, [
              ChatSession(
                keyToken: 'b',
                createdAt: fiveDaysAgo.add(Duration(hours: 4)),
              ),
              ChatSession(keyToken: 'c', goodAnswer: false, createdAt: now),
            ]);

            final second = await AdminStats.dailyStats(session, days: 7);
            expect(second[1].sessionCount, 1);
            expect(second.last.sessionCount, 1);
            expect(second.last.poorAnswerCount, 1);
            expect(await DailyStats.db.count(session), 7);
          },
        );
      });
    },
  );
}
