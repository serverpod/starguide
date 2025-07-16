import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/generated/protocol.dart';

class DocsTableOfContents {
  static const int _batchSize = 20;
  static const String _cacheKey = 'docs_table_of_contents';

  static Future<String> _generateTOC(Session session) async {
    var hasMoreDocuments = true;
    var lastDocumentId = 0;
    StringBuffer toc = StringBuffer();

    while (hasMoreDocuments) {
      final documents = await RAGDocument.db.find(
        session,
        where: (d) => d.id > (lastDocumentId),
        limit: _batchSize,
      );

      if (documents.isEmpty) {
        hasMoreDocuments = false;
      } else {
        lastDocumentId = documents.last.id!;

        for (var document in documents) {
          toc.write('URL: ${document.sourceUrl}\n');
          toc.write('Title: ${document.title}\n');
          toc.write('Description: ${document.shortDescription}\n');
          toc.write('\n');
        }
      }
    }
    return toc.toString();
  }

  static Future<String> getTableOfContents(Session session) async {
    var toc = await session.caches.local.get<TableOfContents>(
      _cacheKey,
      CacheMissHandler(
        () async {
          final toc = await _generateTOC(session);
          return TableOfContents(contents: toc);
        },
        lifetime: const Duration(hours: 1),
      ),
    );
    return toc?.contents ?? '';
  }

  static Future<void> invalidateCache(Session session) async {
    await session.caches.local.invalidateKey(_cacheKey);
  }
}
