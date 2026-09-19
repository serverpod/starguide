import 'package:shad/shad.dart' show LucideIcons;
import 'package:flutter_test/flutter_test.dart';
import 'package:starguide_flutter/chat/starguide_text_message.dart';

void main() {
  test('documentation links are labeled as documentation', () {
    final link = GptResponseLink(
      url: Uri.parse('https://docs.serverpod.dev/concepts/endpoints'),
      title: 'Endpoints',
    );
    expect(link.kind, GptResponseLinkKind.docs);
    expect(link.kindLabel, 'Docs');
    expect(link.kindIcon, LucideIcons.file600);
  });

  test('pages on the Serverpod website are labeled as site', () {
    final link = GptResponseLink(
      url: Uri.parse('https://serverpod.dev/feature/dart-caching'),
      title: 'Caching',
    );
    expect(link.kind, GptResponseLinkKind.site);
    expect(link.kindLabel, 'Site');
    expect(link.kindIcon, LucideIcons.appWindow600);
  });

  test('blog posts on the Serverpod website are labeled as blog', () {
    final link = GptResponseLink(
      url: Uri.parse('https://serverpod.dev/blog/serverpod-4'),
      title: 'Serverpod 4',
    );
    expect(link.kind, GptResponseLinkKind.blog);
    expect(link.kindLabel, 'Blog');
    expect(link.kindIcon, LucideIcons.notebookPen600);
  });

  test('GitHub discussions are labeled as discussions', () {
    final link = GptResponseLink(
      url: Uri.parse('https://github.com/serverpod/serverpod/discussions/123'),
      title: 'How do I deploy?',
    );
    expect(link.kind, GptResponseLinkKind.discussion);
    expect(link.kindLabel, 'Discussion');
    expect(link.kindIcon, LucideIcons.messagesSquare600);
  });

  test('references are parsed from the answer', () {
    final response = GptResponse(
      'The answer.\n\n## References\n'
      '- [Endpoints](https://docs.serverpod.dev/concepts/endpoints)\n'
      '- [Deploy](https://github.com/serverpod/serverpod/discussions/1)\n'
      '- [Caching](https://serverpod.dev/feature/dart-caching)\n'
      '- [Serverpod 4](https://serverpod.dev/blog/serverpod-4)\n',
    );
    expect(response.text, 'The answer.');
    expect(response.links.map((l) => l.kindLabel), [
      'Docs',
      'Discussion',
      'Site',
      'Blog',
    ]);
  });
}
