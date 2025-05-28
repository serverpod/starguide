import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/data_source.dart';
import 'package:starguide_server/src/generated/protocol.dart';
import 'package:starguide_server/src/generative_ai/generative_ai.dart';
import 'package:starguide_server/src/generative_ai/prompts.dart';

class DataFetcher {
  final List<DataSource> dataSources;
  final Duration cacheDuration;

  DataFetcher({
    required this.dataSources,
    this.cacheDuration = const Duration(days: 1),
  });

  Future<void> fetchAndOrganize(Session session) async {
    // Setup Generative AI.

    // Start fetching data.
    session.log('Start fetching data.');
    for (var dataSource in dataSources) {
      await for (final rawDocument in dataSource.fetch(session, this)) {
        session.log('Loaded document: ${rawDocument.sourceUrl}');

        final ragDocument = await _createRagDocument(session, rawDocument);
        await _saveRagDocument(session, ragDocument);

        // Pause as to not exhuast Gemini's free tier.
        await Future.delayed(const Duration(seconds: 10));
      }
    }
    session.log('Fetching data done.');
  }

  Future<RAGDocument> _createRagDocument(
    Session session,
    RawRAGDocuement rawDocument,
  ) async {
    final genAi = GenerativeAi();

    session.log('Summarizing document, length: ${rawDocument.document.length}');
    final summary = await genAi.generateSimpleAnswer(
      Prompts.instance.get('summarize_document')! + rawDocument.document,
    );

    session.log('Generating embedding for summary, length: ${summary.length}');
    final embedding = await genAi.generateEmbedding(summary);

    session.log('Embeddings generated.');

    return RAGDocument(
      sourceUrl: rawDocument.sourceUrl,
      fetchTime: DateTime.now(),
      content: rawDocument.document,
      summary: summary,
      embedding: embedding,
    );
  }

  Future<void> _saveRagDocument(
    Session session,
    RAGDocument ragDocument,
  ) async {
    print('Saving rag document: ${ragDocument.sourceUrl}');

    final existingDocument = await RAGDocument.db.findFirstRow(
      session,
      where: (t) => t.sourceUrl.equals(ragDocument.sourceUrl),
    );

    if (existingDocument == null) {
      await RAGDocument.db.insertRow(session, ragDocument);
    } else {
      ragDocument.id = existingDocument.id;
      await RAGDocument.db.updateRow(
        session,
        ragDocument,
      );
    }
  }

  Future<bool> shouldFetchUrl(Session session, Uri sourceUrl) async {
    session.log('Checking if should fetch url: $sourceUrl');

    // Check if the url is already in the database.
    final document = await RAGDocument.db.findFirstRow(
      session,
      where: (t) =>
          t.sourceUrl.equals(sourceUrl) &
          (t.fetchTime > (DateTime.now().subtract(cacheDuration))),
    );
    return document == null;
  }
}
