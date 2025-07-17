import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/business/docs_table_of_contents.dart';
import 'package:starguide_server/src/generative_ai/generative_ai.dart';
import 'package:starguide_server/src/util/random_string.dart';
import 'package:starguide_server/src/generated/protocol.dart';
import 'package:starguide_server/src/generative_ai/prompts.dart';
import 'package:starguide_server/src/recaptcha/recaptcha.dart';

class StarguideEndpoint extends Endpoint {
  static const _maxConversationLength = 25;
  static const _maxRequestsPerMonth = 10000;

  Future<ChatSession> createChatSession(
    Session session,
    String reCaptchaToken,
  ) async {
    if (Serverpod.instance.runMode != 'development') {
      // Verify the reCAPTCHA token.
      final score = await verifyRecaptchaToken(
        session,
        token: reCaptchaToken,
        expectedAction: 'create_chat_session',
      );

      if (score < 0.5) {
        session.log(
          'Recaptcha score too low: $score',
          level: LogLevel.debug,
        );
        throw RecaptchaException();
      }
    } else {
      session.log('Recaptcha verification skipped in development mode.');
    }

    // Check if max number of requests have been made in the past month and if
    // so, throw an exception.

    // TODO: Use a cache to store the number of requests.
    final requests = await ChatSession.db.count(
      session,
      where: (chatSession) =>
          chatSession.createdAt > (DateTime.now().subtract(Duration(days: 30))),
    );
    if (requests >= _maxRequestsPerMonth) {
      session.log(
        'Too many requests in the past month.',
        level: LogLevel.debug,
      );
      throw Exception('Too many requests in the past month.');
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

    if (conversation.length >= _maxConversationLength) {
      throw FormatException('Conversation too long.');
    }

    final genAi = GenerativeAi();

    var documents = <RAGDocument>[];

    // Search documentation for the most relevant URLs.
    final toc = await DocsTableOfContents.getTableOfContents(session);
    final urls = await genAi.generateUrlList(
      Prompts.instance.get('search_toc_0')! +
          toc +
          Prompts.instance.get('search_toc_1')! +
          question,
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
    documents.addAll(await RAGDocument.db.find(
      session,
      orderBy: (rag) => rag.embedding.distanceCosine(embedding),
      where: (t) => t.type.equals(RAGDocumentType.discussion),
      limit: 5,
    ));

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
