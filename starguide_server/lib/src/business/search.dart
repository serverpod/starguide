import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/document_index.dart';
import 'package:starguide_server/src/generated/protocol.dart';
import 'package:starguide_server/src/generative_ai/generative_ai.dart';
import 'package:starguide_server/src/generative_ai/jev.dart';
import 'package:starguide_server/src/generative_ai/prompts.dart';

/// The document types that are found by embedding search, as opposed to
/// being picked from the document index by [searchDocumentation].
const embeddingSearchTypes = {RAGDocumentType.discussion, RAGDocumentType.blog};

/// Finds the documentation and website pages most likely to answer the
/// question, by letting Jev pick them from the [DocumentIndex].
///
/// Returns nothing if Jev is not configured. Throws a
/// [GenerativeAiException] if Jev cannot be reached.
Future<List<RAGDocument>> searchDocumentation(
  Session session,
  List<ChatMessage> conversation,
  String question,
) async {
  final jev = Jev.instance;
  if (jev == null) {
    session.log(
      'The ${Jev.passwordKey} password is not set, so no documentation '
      'pages are picked.',
      level: LogLevel.warning,
    );
    return const [];
  }

  final totalStopwatch = Stopwatch()..start();
  final timings = <String, Duration>{};

  final getIndexStopwatch = Stopwatch()..start();
  final index = await DocumentIndexCache.get(session);
  getIndexStopwatch.stop();
  timings['getDocumentIndex'] = getIndexStopwatch.elapsed;

  final pickStopwatch = Stopwatch()..start();
  final picks = await jev.pickDocuments(session, index, conversation, question);
  pickStopwatch.stop();
  timings['pickDocuments'] = pickStopwatch.elapsed;

  final findDocumentsStopwatch = Stopwatch()..start();
  final documents = <RAGDocument>[];
  if (picks.isNotEmpty) {
    final ids = <int>{for (final pick in picks) pick.documentId};
    final found = await RAGDocument.db.find(
      session,
      where: (t) => t.id.inSet(ids),
    );
    final byId = {for (final document in found) document.id!: document};

    // Keep Jev's order, best first. A picked page may have been removed
    // since the index was built.
    for (final pick in picks) {
      final document = byId[pick.documentId];
      if (document != null) documents.add(document);
    }
  }
  findDocumentsStopwatch.stop();
  timings['findDocuments'] = findDocumentsStopwatch.elapsed;

  totalStopwatch.stop();
  timings['total'] = totalStopwatch.elapsed;

  // Log performance measurements
  final timingStrings = timings.entries
      .map((e) => '${e.key}: ${e.value.inMilliseconds}ms')
      .join(', ');
  session.log(
    'searchDocumentation() performance: $timingStrings',
    level: LogLevel.debug,
  );

  return documents;
}

/// Finds the discussions and blog posts closest to the question, by comparing
/// the embedding of the question with the embeddings of the documents.
Future<List<RAGDocument>> searchByEmbedding(
  Session session,
  List<ChatMessage> conversation,
  String question,
) async {
  final totalStopwatch = Stopwatch()..start();
  final timings = <String, Duration>{};

  final genAi = GenerativeAi();

  // Transform the question to a question to what it like looks like in the
  // RAG database.
  final transformQuestionStopwatch = Stopwatch()..start();
  String transformedQuestion;
  if (conversation.isEmpty) {
    transformedQuestion = await genAi.generateSimpleAnswer(
      Prompts.instance.get('transform_first_question')! + question,
    );
  } else {
    final answerStream = genAi.generateConversationalAnswer(
      systemPrompt: Prompts.instance.get('transform_followup_question')!,
      question: question,
      documents: [],
      conversation: conversation,
      quality: ModelQuality.fast,
    );

    // Concatenate the answer stream.
    var answer = '';
    await for (var chunk in answerStream) {
      answer += chunk;
    }
    transformedQuestion = answer;
  }
  transformQuestionStopwatch.stop();
  timings['transformQuestion'] = transformQuestionStopwatch.elapsed;

  // Create an embedding for the question.
  final generateEmbeddingStopwatch = Stopwatch()..start();
  final embedding = await genAi.generateEmbedding(transformedQuestion);
  generateEmbeddingStopwatch.stop();
  timings['generateEmbedding'] = generateEmbeddingStopwatch.elapsed;

  // Find the most similar documents in the RAG database.
  final findDocumentsStopwatch = Stopwatch()..start();
  final documents = await RAGDocument.db.find(
    session,
    orderBy: (rag) => rag.embedding.distanceCosine(embedding),
    where: (t) => t.type.inSet(embeddingSearchTypes),
    limit: 5,
  );
  findDocumentsStopwatch.stop();
  timings['findDocuments'] = findDocumentsStopwatch.elapsed;

  totalStopwatch.stop();
  timings['total'] = totalStopwatch.elapsed;

  // Log performance measurements
  final timingStrings = timings.entries
      .map((e) => '${e.key}: ${e.value.inMilliseconds}ms')
      .join(', ');
  session.log(
    'searchByEmbedding() performance: $timingStrings',
    level: LogLevel.debug,
  );

  return documents;
}
