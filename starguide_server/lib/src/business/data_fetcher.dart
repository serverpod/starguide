import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_source.dart';
import 'package:starguide_server/src/business/docs_table_of_contents.dart';
import 'package:starguide_server/src/generated/protocol.dart';
import 'package:starguide_server/src/generative_ai/generative_ai.dart';
import 'package:starguide_server/src/generative_ai/prompts.dart';

class DataFetcher {
  static DataFetcher? _instance;

  static const fetchRetryDelay = Duration(minutes: 1);

  final List<DataSource> dataSources;
  final Duration cacheDuration;
  final Duration removeOldDataAfter;

  static void configure(
    List<DataSource> dataSources, {
    Duration cacheDuration = const Duration(days: 1),
    Duration removeOldDataAfter = const Duration(days: 3),
  }) {
    _instance ??= DataFetcher._(
      dataSources: dataSources,
      cacheDuration: cacheDuration,
      removeOldDataAfter: removeOldDataAfter,
    );
  }

  static DataFetcher get instance => _instance!;

  DataFetcher._({
    required this.dataSources,
    this.cacheDuration = const Duration(days: 1),
    this.removeOldDataAfter = const Duration(days: 3),
  });

  Future<void> fetchDataSource(Session session, DataSource dataSource) async {
    await for (final rawDocument in dataSource.fetch(session, this)) {
      session.log(
        'Loaded document: ${rawDocument.sourceUrl}',
        level: LogLevel.debug,
      );

      final ragDocument = await _createRagDocument(session, rawDocument);
      await _saveRagDocument(session, ragDocument);

      // Pause as to not exhaust Gemini's quota
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<RAGDocument> _createRagDocument(
    Session session,
    RawRAGDocument rawDocument,
  ) async {
    final genAi = GenerativeAi();

    session.log('Summarizing document for description.', level: LogLevel.debug);
    final shortDescription = await genAi.generateSimpleAnswer(
      Prompts.instance.get('summarize_document_for_description')! +
          rawDocument.document,
    );

    session.log('Summarizing document for embedding.', level: LogLevel.debug);
    final embeddingSummary = await genAi.generateSimpleAnswer(
      Prompts.instance.get('summarize_document_for_embedding')! +
          rawDocument.document,
    );

    session.log('Generating embedding for summary.', level: LogLevel.debug);
    final embedding = await genAi.generateEmbedding(embeddingSummary);

    session.log('Embeddings generated.', level: LogLevel.debug);

    return RAGDocument(
      title: rawDocument.title,
      sourceUrl: rawDocument.sourceUrl,
      fetchTime: DateTime.now(),
      content: rawDocument.document,
      embeddingSummary: embeddingSummary,
      shortDescription: shortDescription,
      embedding: embedding,
      type: rawDocument.documentType,
      domain: rawDocument.domain,
    );
  }

  Future<void> _saveRagDocument(
    Session session,
    RAGDocument ragDocument,
  ) async {
    session.log(
      'Saving rag document: ${ragDocument.sourceUrl}',
      level: LogLevel.debug,
    );

    final existingDocument = await RAGDocument.db.findFirstRow(
      session,
      where: (t) => t.sourceUrl.equals(ragDocument.sourceUrl),
    );

    if (existingDocument == null) {
      await RAGDocument.db.insertRow(session, ragDocument);
    } else {
      ragDocument.id = existingDocument.id;
      await RAGDocument.db.updateRow(session, ragDocument);
    }

    if (ragDocument.type == RAGDocumentType.documentation) {
      await DocsTableOfContents.invalidateCache(session);
    }
  }

  Future<bool> shouldFetchUrl(Session session, Uri sourceUrl) async {
    session.log(
      'Checking if should fetch url: $sourceUrl',
      level: LogLevel.debug,
    );

    final document = await RAGDocument.db.findFirstRow(
      session,
      where: (t) =>
          t.sourceUrl.equals(sourceUrl) &
          (t.fetchTime > (DateTime.now().subtract(cacheDuration))),
    );
    return document == null;
  }

  Future<void> cleanUp(Session session) async {
    await RAGDocument.db.deleteWhere(
      session,
      where: (t) => t.fetchTime < DateTime.now().subtract(removeOldDataAfter),
    );
  }
}
