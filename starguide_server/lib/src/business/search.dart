import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/docs_table_of_contents.dart';
import 'package:starguide_server/src/generated/protocol.dart';
import 'package:starguide_server/src/generative_ai/generative_ai.dart';
import 'package:starguide_server/src/generative_ai/prompts.dart';

Future<List<RAGDocument>> searchDocumentation(
  Session session,
  List<ChatMessage> conversation,
  String question,
) async {
  final totalStopwatch = Stopwatch()..start();
  final timings = <String, Duration>{};

  final genAi = GenerativeAi();
  var documents = <RAGDocument>[];

  // Search documentation for the most relevant URLs.
  final getTocStopwatch = Stopwatch()..start();
  final toc = await DocsTableOfContents.getTableOfContents(session);
  getTocStopwatch.stop();
  timings['getTableOfContents'] = getTocStopwatch.elapsed;

  print('TOC:\n$toc');

  final generateUrlsStopwatch = Stopwatch()..start();
  final urls = await genAi.generateUrlList(
    systemPrompt: Prompts.instance.get('search_toc')! + toc,
    conversation: [
      ...conversation,
      ChatMessage(
        chatSessionId: 0,
        message: question,
        type: ChatMessageType.user,
      ),
    ],
  );
  generateUrlsStopwatch.stop();
  timings['generateUrlList'] = generateUrlsStopwatch.elapsed;

  final findDocumentsStopwatch = Stopwatch()..start();
  for (final url in urls) {
    var document = await RAGDocument.db.findFirstRow(
      session,
      where: (t) => t.sourceUrl.equals(url),
    );

    if (document != null) {
      documents.add(document);
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

Future<List<RAGDocument>> searchDiscussions(
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

  // Find the most similar question in the RAG database.
  final findDocumentsStopwatch = Stopwatch()..start();
  final documents = await RAGDocument.db.find(
    session,
    orderBy: (rag) => rag.embedding.distanceCosine(embedding),
    where: (t) => t.type.equals(RAGDocumentType.discussion),
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
    'searchDiscussions() performance: $timingStrings',
    level: LogLevel.debug,
  );

  return documents;
}
