import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:json_schema/json_schema.dart';
import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/extensions/chat_message_to_role.dart';
import 'package:starguide_server/src/generated/protocol.dart';

const String _geminiModelName = 'gemini-2.0-flash';
const String _geminiEmbeddingModelName = 'gemini-embedding-exp-03-07';

class GenerativeAi {
  final String _geminiAPIKey;

  GenerativeAi()
      : _geminiAPIKey = Serverpod.instance.getPassword('geminiAPIKey')!;

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
          parts: [TextPart(chatMessage.message)],
        ),
      );
    }

    final agentWithSystem = _createAgent(
      systemPrompt:
          systemPrompt + documents.map((e) => _formatDocument(e)).join('\n'),
    );
    final response = agentWithSystem.runStream(question, messages: messages);
    await for (final chunk in response) {
      yield chunk.output;
    }
  }

  Future<String> generateSimpleAnswer(String question) async {
    final agent = _createAgent();
    final response = await agent.run(question);
    return response.output;
  }

  Future<Vector> generateEmbedding(String document) async {
    final agent = _createAgent();
    final embedding = await agent.createEmbedding(
      document,
      dimensions: 1536,
    );
    return Vector(embedding.toList());
  }

  Future<List<Uri>> generateUrlList(String question) async {
    final agent = _createAgent(
      systemPrompt: 'Please reploy ONLY with JSON containing a field of "urls" '
          'which is a list of URLs. If you cannot find any URLs, return an '
          'empty list.',
      outputSchema: _UrlList.schemaMap.toSchema(),
      outputFromJson: _UrlList.fromJson,
    );
    final response = await agent.runFor<_UrlList>(
      question,
    );
    return response.output.urls.map((str) => Uri.parse(str)).toList();
  }

  String _formatDocument(RAGDocument document) {
    return '<doc href="${document.sourceUrl}">\n${document.content}\n</doc>';
  }

  Agent _createAgent({
    String? systemPrompt,
    JsonSchema? outputSchema,
    dynamic Function(Map<String, dynamic> json)? outputFromJson,
  }) {
    return Agent.provider(
      GeminiProvider(
        apiKey: _geminiAPIKey,
        modelName: _geminiModelName,
        embeddingModelName: _geminiEmbeddingModelName,
      ),
      systemPrompt: systemPrompt,
      outputSchema: outputSchema,
      outputFromJson: outputFromJson,
    );
  }
}

class _UrlList {
  final List<String> urls;

  _UrlList({required this.urls});

  factory _UrlList.fromJson(Map<String, dynamic> json) {
    return _UrlList(
      urls: List<String>.from(json['urls'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'urls': urls,
    };
  }

  static Map<String, dynamic> get schemaMap {
    return {
      'type': 'object',
      'properties': {
        'urls': {
          'type': 'array',
          'items': {'type': 'string', 'format': 'uri'},
        },
      },
      'required': ['urls'],
      'additionalProperties': false,
    };
  }
}
