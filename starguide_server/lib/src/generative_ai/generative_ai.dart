import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:json_schema/json_schema.dart';
import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/extensions/chat_message_to_role.dart';
import 'package:starguide_server/src/generated/protocol.dart';

const String _geminiModelName = 'gemini-2.0-flash';
const String _geminiEmbeddingModelName = 'gemini-embedding-exp-03-07';

/// Utility class wrapping access to the Gemini generative AI APIs.
class GenerativeAi {
  final String _geminiAPIKey;

  /// Creates a new [GenerativeAi] using credentials stored in Serverpod.
  GenerativeAi()
      : _geminiAPIKey = Serverpod.instance.getPassword('geminiAPIKey')!;

  /// Generates a streaming conversational answer using provided context.
  ///
  /// [question] is the user query, [systemPrompt] provides instructions for the
  /// model, and [documents] and [conversation] give additional grounding
  /// context.
  Stream<String> generateConversationalAnswer({
    required String question,
    required String systemPrompt,
    List<RAGDocument> documents = const [],
    List<ChatMessage> conversation = const [],
  }) async* {
    final messages = <Message>[];

    // Convert the existing conversation to Gemini message format.
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

    // Create an agent with the system prompt and document context.
    final agentWithSystem = _createAgent(
      systemPrompt:
          systemPrompt + documents.map((e) => _formatDocument(e)).join('\n'),
    );
    final response = agentWithSystem.runStream(question, messages: messages);

    // Yield the streamed answer chunk by chunk.
    await for (final chunk in response) {
      yield chunk.output;
    }
  }

  /// Generates a single, non-streaming answer to [question].
  Future<String> generateSimpleAnswer(String question) async {
    final agent = _createAgent();
    final response = await agent.run(question);
    return response.output;
  }

  /// Creates an embedding vector for the given [document] text.
  Future<Vector> generateEmbedding(String document) async {
    final agent = _createAgent();
    final embedding = await agent.createEmbedding(
      document,
      dimensions: 1536,
    );
    return Vector(embedding.toList());
  }

  /// Generates a list of URL suggestions based on the [systemPrompt] and
  /// conversation context.
  Future<List<Uri>> generateUrlList({
    required String systemPrompt,
    List<ChatMessage> conversation = const [],
  }) async {
    final agent = _createAgent(
      systemPrompt: systemPrompt,
      outputSchema: _UrlList.schemaMap.toSchema(),
      outputFromJson: _UrlList.fromJson,
    );

    final messages = <Message>[];

    // Convert the conversation to the provider's message objects.
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

    // Ask the model for a structured list of URLs.
    final response = await agent.runFor<_UrlList>(
      systemPrompt,
      messages: messages,
    );
    return response.output.urls.map((str) => Uri.parse(str)).toList();
  }

  String _formatDocument(RAGDocument document) {
    return '<doc href="${document.sourceUrl}" type="${document.type.name}" title="${document.title}">\n${document.content}\n</doc>';
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
