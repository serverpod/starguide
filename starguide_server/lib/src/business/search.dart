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
  final genAi = GenerativeAi();
  var documents = <RAGDocument>[];

  // Search documentation for the most relevant URLs.
  final toc = await DocsTableOfContents.getTableOfContents(session);

  print('TOC:\n$toc');

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

  for (final url in urls) {
    var document = await RAGDocument.db.findFirstRow(
      session,
      where: (t) => t.sourceUrl.equals(url),
    );

    if (document != null) {
      documents.add(document);
    }
  }

  return documents;
}

Future<List<RAGDocument>> searchDiscussions(
  Session session,
  List<ChatMessage> conversation,
  String question,
) async {
  final genAi = GenerativeAi();

  // Transform the question to a question to what it like looks like in the
  // RAG database.
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
    );

    // Concatenate the answer stream.
    var answer = '';
    await for (var chunk in answerStream) {
      answer += chunk;
    }
    transformedQuestion = answer;
  }

  // Create an embedding for the question.
  final embedding = await genAi.generateEmbedding(transformedQuestion);

  // Find the most similar question in the RAG database.
  final documents = await RAGDocument.db.find(
    session,
    orderBy: (rag) => rag.embedding.distanceCosine(embedding),
    where: (t) => t.type.equals(RAGDocumentType.discussion),
    limit: 5,
  );

  return documents;
}
