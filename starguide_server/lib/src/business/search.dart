import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/docs_table_of_contents.dart';
import 'package:starguide_server/src/generated/protocol.dart';
import 'package:starguide_server/src/generative_ai/generative_ai.dart';
import 'package:starguide_server/src/generative_ai/prompts.dart';

/// Searches the documentation RAG store for entries relevant to [question].
///
/// Uses generative AI to pick the most relevant documentation URLs based on
/// [conversation] context and returns the matching [RAGDocument]s.
Future<List<RAGDocument>> searchDocumentation(
  Session session,
  List<ChatMessage> conversation,
  String question,
) async {
  final genAi = GenerativeAi();
  var documents = <RAGDocument>[];

  // Ask the AI to suggest the most relevant documentation URLs.
  final toc = await DocsTableOfContents.getTableOfContents(session);
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

  // Load the referenced documents from the database.
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

/// Searches GitHub discussions stored in the RAG database for similar topics.
///
/// The [question] is transformed into the same style as stored discussions and
/// then embedded to find the closest matches.
Future<List<RAGDocument>> searchDiscussions(
  Session session,
  List<ChatMessage> conversation,
  String question,
) async {
  final genAi = GenerativeAi();

  // Transform the question into the expected format stored in the database.
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

    // Concatenate the streamed answer into a single string.
    var answer = '';
    await for (var chunk in answerStream) {
      answer += chunk;
    }
    transformedQuestion = answer;
  }

  // Create an embedding for the transformed question.
  final embedding = await genAi.generateEmbedding(transformedQuestion);

  // Find the most similar discussion in the database using cosine distance.
  final documents = await RAGDocument.db.find(
    session,
    orderBy: (rag) => rag.embedding.distanceCosine(embedding),
    where: (t) => t.type.equals(RAGDocumentType.discussion),
    limit: 5,
  );

  return documents;
}
