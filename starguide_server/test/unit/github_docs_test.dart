import 'package:starguide_server/src/business/data_sources/github_docs.dart';
import 'package:test/test.dart';

void main() {
  group('Given an MDX page importing partials', () {
    const page = '''---
title: ""
---
import MaintainedCommandIntro from './_auth.md';
import Auth from '../../_generated/auth.md';

<MaintainedCommandIntro/>

<Auth />
''';

    final partials = {
      './_auth.md': '# scloud auth\n\nManages your login session.\n',
      '../../_generated/auth.md': '---\ntitle: Auth\n---\n## Usage\n\n```\nscloud auth\n```\n',
    };

    test('when inlining partials then components are replaced with content',
        () async {
      final result = await inlineMdxPartials(
        page,
        (path) async => partials[path],
      );

      expect(result, contains('# scloud auth'));
      expect(result, contains('Manages your login session.'));
      expect(result, contains('## Usage'));
      expect(result, isNot(contains('import ')));
      expect(result, isNot(contains('<MaintainedCommandIntro/>')));
      expect(result, isNot(contains('<Auth />')));
      expect(result, isNot(contains('title: Auth')));
    });

    test('when a partial cannot be loaded then the page is left untouched',
        () async {
      final result = await inlineMdxPartials(page, (path) async => null);
      expect(result, equals(page));
    });
  });

  group('Given nested partials', () {
    test('when inlining then nested imports resolve relative to the partial',
        () async {
      final requested = <String>[];
      final partials = {
        'partials/_outer.md': "import Inner from './_inner.md';\n\n<Inner/>\n",
        'partials/_inner.md': 'Inner content',
      };

      final result = await inlineMdxPartials(
        "import Outer from 'partials/_outer.md';\n\n<Outer/>\n",
        (path) async {
          requested.add(path);
          return partials[path];
        },
      );

      expect(result.trim(), equals('Inner content'));
      expect(requested, equals(['partials/_outer.md', 'partials/_inner.md']));
    });
  });

  group('Given markdown without imports', () {
    test('when inlining then it is returned unchanged', () async {
      const markdown = '# Title\n\nSome text with <Component/> tag.\n';
      final result = await inlineMdxPartials(markdown, (_) async => 'x');
      expect(result, equals(markdown));
    });
  });
}
