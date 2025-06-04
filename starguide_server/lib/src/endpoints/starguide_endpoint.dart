import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/generative_ai/generative_ai.dart';
import 'package:starguide_server/src/business/random_string.dart';
import 'package:starguide_server/src/generated/protocol.dart';
import 'package:starguide_server/src/generative_ai/prompts.dart';
import 'package:starguide_server/src/recaptcha/recaptcha.dart';

class StarguideEndpoint extends Endpoint {
  Future<ChatSession> createChatSession(
    Session session,
    String reCaptchaToken,
  ) async {
    // Verify the reCAPTCHA token.
    final score = await verifyRecaptchaToken(
      session,
      token: reCaptchaToken,
      expectedAction: 'create_chat_session',
    );

    if (score < 0.5) {
      throw RecaptchaException();
    }

    // Create a new chat session.
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
    final String question,
  ) async* {
    // Verify that the session is valid.
    await _verifyChatSession(session, chatSession);

    // Find earlier conversation.
    final conversation = await ChatMessage.db.find(
      session,
      where: (chatMessage) => chatMessage.chatSessionId.equals(chatSession.id!),
      orderBy: (chatMessage) => chatMessage.id,
    );

    final genAi = GenerativeAi();

    var documents = <RAGDocument>[];

    String transformedQuestion;

    // Transform the question to a question to what it like looks like in the
    // RAG database.
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
    documents = await RAGDocument.db.find(
      session,
      orderBy: (rag) => rag.embedding.distanceCosine(embedding),
      limit: 5,
    );

    // Generate the answer
    final answerStream = genAi.generateConversationalAnswer(
      systemPrompt: Prompts.instance.get('final_answer')!,
      question: question,
      documents: documents,
      conversation: conversation,
    );
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

  Future<void> vote(
    Session session,
    ChatSession chatSession,
    bool goodAnswer,
  ) async {
    // Verify that the chat session is valid.
    await _verifyChatSession(session, chatSession);

    // Update the chat session with the vote.
    chatSession.goodAnswer = goodAnswer;
    await ChatSession.db.updateRow(session, chatSession);
  }

  Future<void> _verifyChatSession(
    Session session,
    ChatSession chatSession,
  ) async {
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
  }
}
