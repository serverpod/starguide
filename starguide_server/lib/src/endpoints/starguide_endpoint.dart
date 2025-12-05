import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart';
import 'package:starguide_server/src/business/search.dart';
import 'package:starguide_server/src/config/setup_data_fetcher.dart';
import 'package:starguide_server/src/generative_ai/generative_ai.dart';
import 'package:starguide_server/src/util/random_string.dart';
import 'package:starguide_server/src/generated/protocol.dart';
import 'package:starguide_server/src/generative_ai/prompts.dart';
import 'package:starguide_server/src/recaptcha/recaptcha.dart';

/// Endpoint for chat sessions and Q&A powered by RAG over Serverpod docs.
class StarguideEndpoint extends Endpoint {
  static const _maxConversationLength = 25;
  static const _maxRequestsPerMonth = 10000;
  static const _sessionCountKey = 'session_count';

  /// Creates a new chat session for a user after reCAPTCHA check.
  ///
  /// Throws [RecaptchaException] if reCAPTCHA verification fails in
  /// non-development environments. Limits total monthly requests.
  Future<ChatSession> createChatSession(
    Session session,
    String reCaptchaToken,
  ) async {
    final userId = session.authenticated?.userId;
    if (userId == null) {
      if (Serverpod.instance.runMode != 'development') {
        // Verify the reCAPTCHA token.
        final score = await verifyRecaptchaToken(
          session,
          token: reCaptchaToken,
          expectedAction: 'create_chat_session',
        );

        if (score < 0.5) {
          session.log('Recaptcha score too low: $score', level: LogLevel.debug);
          throw RecaptchaException();
        }
      } else {
        session.log(
          'Recaptcha verification skipped in development mode.',
          level: LogLevel.info,
        );
      }
    }

    // Check if max number of requests have been made in the past month and if
    // so, throw an exception.

    final cachedSessionCount = await session.caches.local.get(
      _sessionCountKey,
      CacheMissHandler(() async {
        final count = await ChatSession.db.count(
          session,
          where: (chatSession) =>
              chatSession.createdAt >
              (DateTime.now().subtract(Duration(days: 30))),
        );
        return CachedSessionCount(count: count);
      }, lifetime: Duration(minutes: 5)),
    );

    if (cachedSessionCount!.count >= _maxRequestsPerMonth) {
      session.log(
        'Too many requests in the past month.',
        level: LogLevel.warning,
      );
      throw Exception('Too many requests in the past month.');
    }

    // Create a new chat session.
    return await ChatSession.db.insertRow(
      session,
      ChatSession(
        userId: session.authenticated?.userId,
        keyToken: generateRandomString(16),
      ),
    );
  }

  /// Asks a question and streams the generated answer as chunks.
  ///
  /// Combines previous conversation context with searched RAG documents
  /// from docs and discussions to produce the answer.
  Stream<String> ask(
    Session session,
    ChatSession chatSession,
    final String question,
  ) async* {
    final totalStopwatch = Stopwatch()..start();
    final timings = <String, Duration>{};

    // Verify that the session is valid.
    final verifyStopwatch = Stopwatch()..start();
    await _verifyChatSession(session, chatSession);
    verifyStopwatch.stop();
    timings['verifyChatSession'] = verifyStopwatch.elapsed;

    // Find earlier conversation.
    final findConversationStopwatch = Stopwatch()..start();
    final conversation = await ChatMessage.db.find(
      session,
      where: (chatMessage) => chatMessage.chatSessionId.equals(chatSession.id!),
      orderBy: (chatMessage) => chatMessage.id,
    );
    findConversationStopwatch.stop();
    timings['findConversation'] = findConversationStopwatch.elapsed;

    if (conversation.length >= _maxConversationLength) {
      throw FormatException('Conversation too long.');
    }

    final genAi = GenerativeAi();

    // Search RAG documents in parallel, using different methods.
    final searchStopwatch = Stopwatch()..start();
    final results = await Future.wait([
      searchDocumentation(session, conversation, question),
      searchDiscussions(session, conversation, question),
    ]);
    var documents = results.expand((list) => list).toList();
    searchStopwatch.stop();
    timings['searchDocuments'] = searchStopwatch.elapsed;

    // Generate the answer
    final generateStopwatch = Stopwatch()..start();
    final answerStream = genAi.generateConversationalAnswer(
      systemPrompt:
          'The latest version of Serverpod is '
          '$latestServerpodVersion.\n${Prompts.instance.get('final_answer')!}',
      question: question,
      documents: documents,
      conversation: conversation,
    );
    var answer = '';
    await for (var chunk in answerStream) {
      answer += chunk;
      yield chunk;
    }
    generateStopwatch.stop();
    timings['generateAnswer'] = generateStopwatch.elapsed;

    // Store the question and the answer.
    final storeStopwatch = Stopwatch()..start();
    await ChatMessage.db.insert(session, [
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
    ]);
    storeStopwatch.stop();
    timings['storeMessages'] = storeStopwatch.elapsed;

    totalStopwatch.stop();
    timings['total'] = totalStopwatch.elapsed;

    // Log performance measurements
    final timingStrings = timings.entries
        .map((e) => '${e.key}: ${e.value.inMilliseconds}ms')
        .join(', ');
    session.log('ask() performance: $timingStrings', level: LogLevel.debug);
  }

  /// Records a thumbs up or down for the final answer of a chat session.
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

  /// Verifies that a provided chat session exists and has a matching key.
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
