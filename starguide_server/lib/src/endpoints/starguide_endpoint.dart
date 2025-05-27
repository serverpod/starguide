import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/generative_ai.dart';
import 'package:starguide_server/src/business/random_string.dart';
import 'package:starguide_server/src/generated/protocol.dart';

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

    // Generate the answer
    final genAi = GenerativeAi();
    final answerStream = genAi.generateAnswer(question, conversation);
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
