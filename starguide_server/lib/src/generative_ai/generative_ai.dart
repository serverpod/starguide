import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/extensions/chat_message_to_role.dart';
import 'package:starguide_server/src/generated/protocol.dart';

class GenerativeAi {
  final String _geminiAPIKey;
  late Agent _agent;

  GenerativeAi()
      : _geminiAPIKey = Serverpod.instance.getPassword('geminiAPIKey')! {
    _agent = _getAgent();
  }

  Stream<String> generateConversationalAnswer({
    required String question,
    required String systemPrompt,
    List<RAGDocument> documents = const [],
    List<ChatMessage> conversation = const [],
  }) async* {
    final messages = <Message>[];

    // Add conversation history
    for (final chatMessage in conversation) {
      messages.add(
        Message(
          role: chatMessage.type.aiRole == 'user'
              ? MessageRole.user
              : MessageRole.model,
          content: [TextPart(chatMessage.message)],
        ),
      );
    }

    final agentWithSystem = _getAgent(
      systemPrompt + documents.map((e) => _formatDocument(e)).join('\n'),
    );
    final response = agentWithSystem.runStream(question, messages: messages);
    await for (final chunk in response) {
      yield chunk.output;
    }
  }

  Future<String> generateSimpleAnswer(String question) async {
    final response = await _agent.run(question);
    return response.output;
  }

  Future<Vector> generateEmbedding(String document) async {
    final embedding = await _agent.createEmbedding(document);
    return Vector(embedding.toList());
  }

  String _formatDocument(RAGDocument document) {
    return '<doc href="${document.sourceUrl}">\n${document.content}\n</doc>';
  }

  Agent _getAgent([String? systemPrompt]) => Agent.provider(
        // pick a specific provider and embedding model -- embeddings aren't
        // compatible between providers and not guaranteed to be compatible between
        // models. picking a specific model name isn't as important -- those can
        // change over time w/o affecting the embeddings.
        GeminiProvider(
          apiKey: _geminiAPIKey,
          modelName: 'gemini-2.0-flash',
          embeddingModelName: 'text-embedding-004',
        ),
        systemPrompt: systemPrompt,
      );
}
