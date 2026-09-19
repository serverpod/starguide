import 'package:starguide_server/src/business/data_sources/website.dart';
import 'package:starguide_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  group('Given the JSON index of a website collection', () {
    const index = '''
{"collection":"blog","pages":[
  {"slug":"serverpod-4","title":"Serverpod 4","description":"Release notes",
   "date":"2026-09-14T22:00:00.000Z","author":"Viktor Lidholt","tag":"Release",
   "url":"https://serverpod.dev/blog/serverpod-4",
   "markdownUrl":"https://serverpod.dev/markdown/blog/serverpod-4.md"},
  {"slug":"dart-caching","title":"Caching","description":"Caching with Redis.",
   "url":"https://serverpod.dev/feature/dart-caching",
   "markdownUrl":"https://serverpod.dev/markdown/feature/dart-caching.md"}
]}''';

    test('when parsing then every page is listed with its URLs', () {
      final pages = parseWebsiteIndex(index);

      expect(pages, hasLength(2));
      expect(pages[0].title, 'Serverpod 4');
      expect(pages[0].url, Uri.parse('https://serverpod.dev/blog/serverpod-4'));
      expect(
        pages[0].markdownUrl,
        Uri.parse('https://serverpod.dev/markdown/blog/serverpod-4.md'),
      );
      expect(pages[0].date, DateTime.utc(2026, 9, 14, 22));
      expect(pages[0].author, 'Viktor Lidholt');
      expect(pages[1].date, isNull);
      expect(pages[1].author, isNull);
    });
  });

  group('Given the Markdown version of a website page', () {
    const markdown = '''---
title: "Caching"
description: "Optimize your server by caching locally or using Redis."
url: "https://serverpod.dev/feature/dart-caching"
---

Store expensive results once and serve them from memory or Redis.

## Type-safe caching
''';

    final page = WebsitePage(
      title: 'Caching',
      url: Uri.parse('https://serverpod.dev/feature/dart-caching'),
      markdownUrl: Uri.parse(
        'https://serverpod.dev/markdown/feature/dart-caching.md',
      ),
    );

    test('when building the document then the frontmatter is replaced by a '
        'heading with the title and the page URL is the source', () {
      final document = websiteDocument(
        page,
        markdown,
        domain: 'Serverpod',
        documentType: RAGDocumentType.site,
      );

      expect(
        document.document,
        '# Caching\n\n'
        'Store expensive results once and serve them from memory or Redis.\n'
        '\n## Type-safe caching',
      );
      expect(document.title, 'Caching');
      expect(document.sourceUrl, page.url);
      expect(document.documentType, RAGDocumentType.site);
      expect(document.domain, 'Serverpod');
    });

    test('when the page has a date and an author then they are stated below '
        'the heading', () {
      final post = WebsitePage(
        title: 'Serverpod 4',
        url: Uri.parse('https://serverpod.dev/blog/serverpod-4'),
        markdownUrl: Uri.parse(
          'https://serverpod.dev/markdown/blog/serverpod-4.md',
        ),
        date: DateTime.utc(2026, 9, 14, 22),
        author: 'Viktor Lidholt',
      );

      final document = websiteDocument(
        post,
        markdown,
        domain: 'Serverpod',
        documentType: RAGDocumentType.blog,
      );

      expect(
        document.document,
        startsWith(
          '# Serverpod 4\n\nPublished on 2026-09-14 by Viktor Lidholt.\n\n',
        ),
      );
    });
  });
}
