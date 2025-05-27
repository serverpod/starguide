import 'dart:io';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:serverpod/serverpod.dart';
import 'package:starguide_server/src/extensions/chat_message_to_role.dart';
import 'package:starguide_server/src/generated/chat_message.dart';

// final model = GenerativeModel(
//   model: 'gemini-2.0-flash-latest',
//   apiKey: 'AIzaSyD8shlq0fh996iMLA47n5O7NN6cBPiMzVo',
// );

// final embeddingModel = GenerativeModel(
//   model: 'gemini-embedding-exp-03-07',
//   apiKey: 'AIzaSyD8shlq0fh996iMLA47n5O7NN6cBPiMzVo',
// );

class GenerativeAi {
  late final String geminiAPIKey;
  late GenerativeModel model;
  late GenerativeModel embeddingModel;

  GenerativeAi() {
    geminiAPIKey = Serverpod.instance.getPassword('geminiAPIKey')!;
    model = GenerativeModel(
      model: 'gemini-2.0-flash-latest',
      apiKey: geminiAPIKey,
    );
    embeddingModel = GenerativeModel(
      model: 'gemini-embedding-exp-03-07',
      apiKey: geminiAPIKey,
    );
  }

  Stream<String> generateAnswer(
      String question, List<ChatMessage> conversation) {
    final systemInstructionsStr =
        File('system_prompt_2.txt').readAsStringSync();

    final prompt = conversation.map(
      (chatMessage) {
        return Content(
          chatMessage.type.aiRole,
          [TextPart(chatMessage.message)],
        );
      },
    ).toList();

    prompt.add(Content.text(question));

    prompt.insert(0, Content.text(systemInstructionsStr));

    return model
        .generateContentStream(prompt)
        .map<String>((response) => response.text ?? '');
  }

  Future<void> findEmbedding(String document) async {
    var response = await embeddingModel.embedContent(
      Content.text(document),
      outputDimensionality: 1536,
    );
    print('embedding length: ${response.embedding.values.length}');
  }
}
