import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_fetcher.dart';
import 'package:starguide_server/src/business/data_source.dart';
import 'package:starguide_server/src/business/data_source_exception.dart';
import 'package:starguide_server/src/business/data_sources/markdown_frontmatter.dart';
import 'package:starguide_server/src/generated/protocol.dart';

/// Fetches the pages of one or more collections on a website, e.g.
/// serverpod.dev, that publishes a Markdown version of its pages.
///
/// Each of [indexUrls] returns a JSON index of a collection, listing the
/// pages with the URL of the published page and the URL of its Markdown
/// version, see [WebsitePage]. Documents are stored under the URL of the
/// published page, so references in answers point at the website rather
/// than the Markdown files.
class WebsiteDataSource implements DataSource {
  final List<Uri> indexUrls;
  @override
  final String domain;
  @override
  final RAGDocumentType documentType;
  @override
  final String description;

  final http.Client _client;

  WebsiteDataSource({
    required this.indexUrls,
    required this.domain,
    required this.documentType,
    required this.description,
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  String get name =>
      'Website:${indexUrls.map((url) => url.pathSegments.last).join(',')}';

  @override
  Stream<RawRAGDocument> fetch(Session session, DataFetcher fetcher) async* {
    for (final indexUrl in indexUrls) {
      final response = await _client.get(indexUrl);
      if (response.statusCode != 200) {
        throw DataSourceException(
          'Failed to fetch website index $indexUrl',
          statusCode: response.statusCode,
        );
      }

      final pages = parseWebsiteIndex(response.body);
      session.log(
        'Found ${pages.length} pages in $indexUrl',
        level: LogLevel.debug,
      );

      for (final page in pages) {
        if (!await fetcher.shouldFetchUrl(session, page.url)) continue;

        final markdownResponse = await _client.get(page.markdownUrl);
        if (markdownResponse.statusCode != 200) {
          session.log(
            'Failed to fetch ${page.markdownUrl}: '
            '${markdownResponse.statusCode}',
            level: LogLevel.warning,
          );
          continue;
        }

        yield websiteDocument(
          page,
          markdownResponse.body,
          domain: domain,
          documentType: documentType,
        );
      }
    }
  }
}

/// A page listed in a website's collection index.
class WebsitePage {
  final String title;
  final Uri url;
  final Uri markdownUrl;
  final DateTime? date;
  final String? author;

  WebsitePage({
    required this.title,
    required this.url,
    required this.markdownUrl,
    this.date,
    this.author,
  });

  factory WebsitePage.fromJson(Map<String, dynamic> json) {
    final date = json['date'] as String?;
    return WebsitePage(
      title: json['title'] as String,
      url: Uri.parse(json['url'] as String),
      markdownUrl: Uri.parse(json['markdownUrl'] as String),
      date: date == null ? null : DateTime.tryParse(date),
      author: json['author'] as String?,
    );
  }
}

/// Parses the JSON index of a website collection, which has the form
/// `{"collection": "blog", "pages": [...]}`.
List<WebsitePage> parseWebsiteIndex(String jsonString) {
  final json = jsonDecode(jsonString) as Map<String, dynamic>;
  final pages = json['pages'] as List<dynamic>;
  return [
    for (final page in pages)
      WebsitePage.fromJson(page as Map<String, dynamic>),
  ];
}

/// Builds the document for [page] from its Markdown version. The frontmatter
/// is replaced by a heading with the page's title, so the document has the
/// same shape as a documentation page, followed by the publication date and
/// author when known.
RawRAGDocument websiteDocument(
  WebsitePage page,
  String markdown, {
  required String domain,
  required RAGDocumentType documentType,
}) {
  final document = StringBuffer('# ${page.title}\n\n');

  final date = page.date;
  final author = page.author;
  if (date != null || author != null) {
    document.write('Published');
    if (date != null) {
      document.write(' on ${date.toIso8601String().substring(0, 10)}');
    }
    if (author != null) document.write(' by $author');
    document.write('.\n\n');
  }

  document.write(stripFrontmatter(markdown).trim());

  return RawRAGDocument(
    sourceUrl: page.url,
    document: document.toString(),
    title: page.title,
    dataSourceType: DataSourceType.markdown,
    documentType: documentType,
    domain: domain,
  );
}
