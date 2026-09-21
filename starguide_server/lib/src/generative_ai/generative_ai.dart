import 'package:dartantic_ai/dartantic_ai.dart' as ai;

import 'package:serverpod/serverpod.dart' hide Message;
import 'package:starguide_server/src/extensions/chat_message_to_role.dart';
import 'package:starguide_server/src/generated/protocol.dart';

class GenerativeAi {
  final String _geminiAPIKey;

  GenerativeAi()
    : _geminiAPIKey = Serverpod.instance.getPassword('geminiAPIKey')!;

  GenerativeAi.withAPIKey(String geminiAPIKey) : _geminiAPIKey = geminiAPIKey;

  Stream<String> generateConversationalAnswer({
    required String question,
    required String systemPrompt,
    List<RAGDocument> documents = const [],
    List<ChatMessage> conversation = const [],
    ModelQuality quality = ModelQuality.smart,
  }) async* {
    final messages = <ai.ChatMessage>[];

    // Add system prompt as the first message
    messages.add(
      ai.ChatMessage.system(
        systemPrompt + documents.map((e) => _formatDocument(e)).join('\n'),
      ),
    );

    // Add conversation history
    for (final chatMessage in conversation) {
      messages.add(
        ai.ChatMessage(
          role: chatMessage.type.aiRole == 'user'
              ? ai.ChatMessageRole.user
              : ai.ChatMessageRole.model,
          parts: [ai.TextPart(chatMessage.message)],
        ),
      );
    }

    final agent = _createAgent(quality: quality);
    try {
      final response = agent.sendStream(question, history: messages);
      await for (final chunk in response) {
        yield chunk.output;
      }
    } catch (e) {
      throw GenerativeAiException(message: e.toString());
    }
  }

  Future<String> generateSimpleAnswer(String question) async {
    final agent = _createAgent();
    try {
      final response = await agent.send(question);
      return response.output;
    } catch (e) {
      throw GenerativeAiException(message: e.toString());
    }
  }

  Future<Vector> generateEmbedding(String document) async {
    final agent = _createAgent();
    try {
      final embedding = await agent.embedQuery(document);
      return Vector(embedding.embeddings);
    } catch (e) {
      throw GenerativeAiException(message: e.toString());
    }
  }

  /// The most characters of a document's content included in the prompt
  /// when generating an answer. The time to the first token grows with the
  /// size of the prompt, and only a few outliers, such as discussions with
  /// pasted logs, are longer than this.
  static const maxDocumentCharacters = 40000;

  /// The thinking budget of the chat models, in tokens. Gemini 2.5 Flash
  /// thinks before its first token unless the budget is zero, which delays
  /// the start of the streamed answer by seconds.
  static const thinkingBudgetTokens = 0;

  String _formatDocument(RAGDocument document) {
    var content = document.content;
    if (content.length > maxDocumentCharacters) {
      content = '${content.substring(0, maxDocumentCharacters)}\n[Truncated]';
    }
    return '<doc href="${document.sourceUrl}" type="${document.type.name}" title="${document.title}">\n$content\n</doc>';
  }

  ai.Agent _createAgent({final ModelQuality quality = ModelQuality.fast}) {
    ai.Agent.environment['GEMINI_API_KEY'] = _geminiAPIKey;
    return ai.Agent(
      quality.model,
      // The thinking budget is only sent when thinking is enabled. Thoughts
      // are never part of the output, so enabling it changes nothing else.
      enableThinking: true,
      chatModelOptions: const ai.GoogleChatModelOptions(
        thinkingBudgetTokens: thinkingBudgetTokens,
      ),
      embeddingsModelOptions: const ai.GoogleEmbeddingsModelOptions(
        dimensions: 768,
      ),
    );
  }
}

extension RAGDocumentTypeName on RAGDocumentType {
  String get name {
    switch (this) {
      case RAGDocumentType.documentation:
        return 'Documentation';
      case RAGDocumentType.site:
        return 'Website Page';
      case RAGDocumentType.discussion:
        return 'GitHub Discussion';
      case RAGDocumentType.blog:
        return 'Blog Post';
      case RAGDocumentType.issue:
        return 'GitHub Issue';
    }
  }
}

enum ModelQuality {
  fast('google?chat=gemini-2.5-flash-lite&embeddings=gemini-embedding-001'),
  smart('google?chat=gemini-2.5-flash&embeddings=gemini-embedding-001');

  const ModelQuality(this.model);

  /// Returns the concrete Google Gemini model that backs this quality level.
  final String model;
}
