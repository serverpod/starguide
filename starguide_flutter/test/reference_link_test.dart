import 'package:shad/shad.dart' show LucideIcons;
import 'package:flutter_test/flutter_test.dart';
import 'package:starguide_flutter/chat/starguide_text_message.dart';

void main() {
  test('documentation links are labeled as documentation', () {
    final link = GptResponseLink(
      url: Uri.parse('https://docs.serverpod.dev/concepts/endpoints'),
      title: 'Endpoints',
    );
    expect(link.isDiscussion, isFalse);
    expect(link.kindLabel, 'Docs');
    expect(link.kindIcon, LucideIcons.file600);
  });

  test('GitHub discussions are labeled as discussions', () {
    final link = GptResponseLink(
      url: Uri.parse('https://github.com/serverpod/serverpod/discussions/123'),
      title: 'How do I deploy?',
    );
    expect(link.isDiscussion, isTrue);
    expect(link.kindLabel, 'Discussion');
    expect(link.kindIcon, LucideIcons.messagesSquare600);
  });

  test('references are parsed from the answer', () {
    final response = GptResponse(
      'The answer.\n\n## References\n'
      '- [Endpoints](https://docs.serverpod.dev/concepts/endpoints)\n'
      '- [Deploy](https://github.com/serverpod/serverpod/discussions/1)\n',
    );
    expect(response.text, 'The answer.');
    expect(response.links.map((l) => l.kindLabel), ['Docs', 'Discussion']);
  });
}
