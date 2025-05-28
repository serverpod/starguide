import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/generative_ai/generative_ai.dart';
import 'package:starguide_server/src/business/random_string.dart';
import 'package:starguide_server/src/generated/protocol.dart';
import 'package:starguide_server/src/generative_ai/prompts.dart';

class StarguideEndpoint extends Endpoint {
  Future<ChatSession> createChatSession(Session session) async {
    return await ChatSession.db.insertRow(
      session,
      ChatSession(
        userId: (await session.authenticated)?.userId,
        keyToken: generateRandomString(16),
      ),
    );
  }

  Stream<String> ask(
    Session session,
    ChatSession chatSession,
    String question,
  ) async* {
    // Verify that the session is valid.
    try {
      final storedChatSession = await ChatSession.db.findById(
        session,
        chatSession.id!,
      );
      if (storedChatSession!.keyToken != chatSession.keyToken) {
        throw Exception('Invalid key token.');
      }
    } catch (e) {
      throw Exception('Invalid chat session.');
    }

    // Find earlier conversation.
    final conversation = await ChatMessage.db.find(
      session,
      where: (chatMessage) => chatMessage.chatSessionId.equals(chatSession.id!),
      orderBy: (chatMessage) => chatMessage.id,
    );

    final genAi = GenerativeAi();

    var documents = <RAGDocument>[];

    if (conversation.isEmpty) {
      // Transform the question to a question to what it like looks like in the
      // RAG database.
      final transformedQuestion = await genAi.generateSimpleAnswer(
        Prompts.instance.get('transform_question')! + question,
      );
      question = transformedQuestion;

      // Create an embedding for the question.
      final embedding = await genAi.generateEmbedding(question);

      // Find the most similar question in the RAG database.
      documents = await RAGDocument.db.find(
        session,
        orderBy: (rag) => rag.embedding.distanceCosine(embedding),
        limit: 5,
      );
    }

    // Generate the answer
    final answerStream =
        genAi.generateConversationalAnswer(question, documents, conversation);
    var answer = '';
    await for (var chunk in answerStream) {
      answer += chunk;
      yield chunk;
    }

    // Store the question and the answer.
    await ChatMessage.db.insert(
      session,
      [
        ChatMessage(
          chatSessionId: chatSession.id!,
          message: question,
          type: ChatMessageType.user,
        ),
        ChatMessage(
          chatSessionId: chatSession.id!,
          message: answer,
          type: ChatMessageType.model,
        ),
      ],
    );
  }
}
