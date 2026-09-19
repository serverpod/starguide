import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/business/data_sources/website.dart';
import 'package:starguide_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

const _index = '''
{"collection":"feature","pages":[
  {"slug":"dart-caching","title":"Caching","description":"Caching.",
   "url":"https://serverpod.dev/feature/dart-caching",
   "markdownUrl":"https://serverpod.dev/markdown/feature/dart-caching.md"},
  {"slug":"flutter-database-orm","title":"Database support",
   "description":"ORM.",
   "url":"https://serverpod.dev/feature/flutter-database-orm",
   "markdownUrl":"https://serverpod.dev/markdown/feature/flutter-database-orm.md"}
]}''';

const _cachingMarkdown = '''---
title: "Caching"
---

Cache locally or with Redis.
''';

const _ormMarkdown = '''---
title: "Database support"
---

A Dart-first ORM.
''';

void main() {
  withServerpod('Given a website data source', (sessionBuilder, endpoints) {
    final requestedUrls = <Uri>[];

    final client = MockClient((request) async {
      requestedUrls.add(request.url);
      return switch (request.url.toString()) {
        'https://serverpod.dev/markdown/feature' => http.Response(_index, 200),
        'https://serverpod.dev/markdown/feature/dart-caching.md' =>
          http.Response(_cachingMarkdown, 200),
        'https://serverpod.dev/markdown/feature/flutter-database-orm.md' =>
          http.Response(_ormMarkdown, 200),
        _ => http.Response('Not found', 404),
      };
    });

    final dataSource = WebsiteDataSource(
      indexUrls: [Uri.parse('https://serverpod.dev/markdown/feature')],
      domain: 'Serverpod',
      documentType: RAGDocumentType.site,
      client: client,
    );

    setUpAll(() {
      DataFetcher.configure([dataSource]);
    });

    setUp(() {
      requestedUrls.clear();
    });

    test('when naming the source then the collections are named', () {
      expect(dataSource.name, 'Website:feature');
    });

    test('when fetching then every listed page is loaded from its Markdown '
        'version and stored under the URL of the published page', () async {
      final session = sessionBuilder.build();

      final documents = await dataSource
          .fetch(session, DataFetcher.instance)
          .toList();

      expect(documents, hasLength(2));
      expect(documents.map((d) => d.sourceUrl.toString()), [
        'https://serverpod.dev/feature/dart-caching',
        'https://serverpod.dev/feature/flutter-database-orm',
      ]);
      expect(documents[0].title, 'Caching');
      expect(
        documents[0].document,
        '# Caching\n\nCache locally or with Redis.',
      );
      expect(documents[0].documentType, RAGDocumentType.site);
      expect(documents[0].domain, 'Serverpod');
    });

    test(
      'when a page was fetched recently then it is not loaded again',
      () async {
        final session = sessionBuilder.build();
        await RAGDocument.db.insertRow(
          session,
          RAGDocument(
            embedding: Vector(List<double>.filled(768, 0)),
            fetchTime: DateTime.now(),
            sourceUrl: Uri.parse('https://serverpod.dev/feature/dart-caching'),
            content: 'Cached content',
            title: 'Caching',
            embeddingSummary: 'Summary',
            shortDescription: 'Description',
            type: RAGDocumentType.site,
            domain: 'Serverpod',
          ),
        );

        final documents = await dataSource
            .fetch(session, DataFetcher.instance)
            .toList();

        expect(documents, hasLength(1));
        expect(documents.single.title, 'Database support');
        expect(
          requestedUrls,
          isNot(
            contains(
              Uri.parse(
                'https://serverpod.dev/markdown/feature/dart-caching.md',
              ),
            ),
          ),
        );
      },
    );

    test('when the index cannot be fetched then fetching fails', () async {
      final session = sessionBuilder.build();
      final failing = WebsiteDataSource(
        indexUrls: [Uri.parse('https://serverpod.dev/markdown/missing')],
        domain: 'Serverpod',
        documentType: RAGDocumentType.site,
        client: client,
      );

      await expectLater(
        failing.fetch(session, DataFetcher.instance).toList(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
