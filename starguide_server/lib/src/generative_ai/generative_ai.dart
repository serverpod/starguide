import 'package:dartantic_ai/dartantic_ai.dart';

import 'package:dartantic_interface/dartantic_interface.dart' as ai;
import 'package:json_schema/json_schema.dart';
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
      final response = agent.sendStream(
        question,
        history: messages,
      );
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

  Future<List<Uri>> generateUrlList({
    required String systemPrompt,
    List<ChatMessage> conversation = const [],
  }) async {
    final messages = <ai.ChatMessage>[];

    // Add system prompt as the first message
    messages.add(ai.ChatMessage.system(systemPrompt));

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

    final agent = _createAgent();

    try {
      final response = await agent.sendFor<_UrlList>(
        systemPrompt,
        history: messages,
        outputSchema: JsonSchema.create(_UrlList.schemaMap),
        outputFromJson: _UrlList.fromJson,
      );
      return response.output.urls.map((str) => Uri.parse(str)).toList();
    } catch (e) {
      throw GenerativeAiException(message: e.toString());
    }
  }

  String _formatDocument(RAGDocument document) {
    return '<doc href="${document.sourceUrl}" type="${document.type.name}" title="${document.title}">\n${document.content}\n</doc>';
  }

  Agent _createAgent({final ModelQuality quality = ModelQuality.fast}) {
    Agent.environment['GEMINI_API_KEY'] = _geminiAPIKey;
    return Agent(
      quality.model,
      embeddingsModelOptions: const GoogleEmbeddingsModelOptions(
        dimensions: 768,
      ),
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

extension RAGDocumentTypeName on RAGDocumentType {
  String get name {
    switch (this) {
      case RAGDocumentType.documentation:
        return 'Documentation';
      case RAGDocumentType.discussion:
        return 'GitHub Discussion';
      case RAGDocumentType.issue:
        return 'GitHub Issue';
    }
  }
}

enum ModelQuality {
  fast('google?chat=gemini-2.5-flash-lite&embeddings=text-embedding-004'),
  smart('google?chat=gemini-2.5-flash&embeddings=text-embedding-004');

  const ModelQuality(this.model);

  /// Returns the concrete Google Gemini model that backs this quality level.
  final String model;
}
