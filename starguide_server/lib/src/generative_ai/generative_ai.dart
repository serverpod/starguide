import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/extensions/chat_message_to_role.dart';
import 'package:starguide_server/src/generated/protocol.dart';

class GenerativeAi {
  late final String geminiAPIKey;
  late GenerativeModel model;
  late GenerativeModel embeddingModel;

  GenerativeAi() {
    geminiAPIKey = Serverpod.instance.getPassword('geminiAPIKey')!;
    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: geminiAPIKey,
    );
    embeddingModel = GenerativeModel(
      model: 'gemini-embedding-exp-03-07',
      apiKey: geminiAPIKey,
    );
  }

  Stream<String> generateConversationalAnswer({
    required String question,
    required String systemPrompt,
    List<RAGDocument> documents = const [],
    List<ChatMessage> conversation = const [],
  }) {
    final prompt = conversation.map(
      (chatMessage) {
        return Content(
          chatMessage.type.aiRole,
          [TextPart(chatMessage.message)],
        );
      },
    ).toList();

    prompt.add(Content.text(question));

    prompt.insert(
      0,
      Content.text(
        systemPrompt + documents.map((e) => _formatDocument(e)).join('\n'),
      ),
    );

    return model
        .generateContentStream(prompt)
        .map<String>((response) => response.text ?? '');
  }

  Future<String> generateSimpleAnswer(String question) async {
    final prompt = [
      Content.text(question),
    ];

    return (await model.generateContent(prompt)).text ?? '';
  }

  Future<Vector> generateEmbedding(String document) async {
    var response = await embeddingModel.embedContent(
      Content.text(document),
      outputDimensionality: 1536,
    );
    return Vector(response.embedding.values);
  }

  String _formatDocument(RAGDocument document) {
    return '<doc href="${document.sourceUrl}">\n${document.content}\n</doc>';
  }
}
