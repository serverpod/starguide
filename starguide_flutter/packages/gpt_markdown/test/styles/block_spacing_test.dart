import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gpt_markdown/custom_widgets/custom_divider.dart';
import 'package:gpt_markdown/custom_widgets/indent_widget.dart';
import 'package:gpt_markdown/custom_widgets/unordered_ordered_list.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

/// The test font is 16 px tall at `height: 1.5`, so a text line is 24 px.
const _style = TextStyle(fontSize: 16, height: 1.5);

Future<void> _pump(
  WidgetTester tester,
  String markdown, {
  BlockSpacing? spacing,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: GptMarkdown(
            markdown,
            style: _style,
            styleSheet: GptMarkdownStyleSheet(
              spacing: spacing,
              // The package's own two pixels around a quote would otherwise
              // add to the margins being measured.
              blockQuote: const BlockQuoteStyle(margin: EdgeInsets.zero),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The vertical space between two rendered blocks.
double _gapBetween(WidgetTester tester, Finder above, Finder below) {
  return tester.getTopLeft(below).dy - tester.getBottomLeft(above).dy;
}

Finder _item(int index) => find.byType(UnorderedListView).at(index);
Finder get _numbered => find.byType(OrderedListView);
Finder get _quote => find.byType(BlockQuoteWidget);
Finder _heading(String text) => find.text(text, findRichText: true);
Finder get _root => find.byWidgetPredicate((w) => w is RichText).first;

const _site = BlockSpacing(
  paragraph: EdgeInsets.only(bottom: 16),
  h2: EdgeInsets.only(top: 36, bottom: 12),
  list: EdgeInsets.only(top: 8, bottom: 16),
  listItem: EdgeInsets.only(bottom: 4),
);

void main() {
  group('BlockSpacing', () {
    testWidgets('items of one list are separated by the item margin', (
      tester,
    ) async {
      await _pump(tester, '- a\n- b', spacing: _site);
      expect(_gapBetween(tester, _item(0), _item(1)), closeTo(4, 0.01));
    });

    testWidgets('a blank line between items does not widen the gap', (
      tester,
    ) async {
      await _pump(tester, '- a\n\n- b', spacing: _site);
      expect(_gapBetween(tester, _item(0), _item(1)), closeTo(4, 0.01));
    });

    testWidgets('the list margin takes over after the last item', (
      tester,
    ) async {
      await _pump(tester, '- a\n\n> q', spacing: _site);
      expect(_gapBetween(tester, _item(0), _quote), closeTo(16, 0.01));
    });

    testWidgets('the list margin takes over before the first item', (
      tester,
    ) async {
      await _pump(tester, '> q\n\n- a', spacing: _site);
      expect(_gapBetween(tester, _quote, _item(0)), closeTo(8, 0.01));
    });

    testWidgets('a numbered list and a bullet list are two lists', (
      tester,
    ) async {
      await _pump(tester, '1. a\n- b', spacing: _site);
      expect(_gapBetween(tester, _numbered, _item(0)), closeTo(16, 0.01));
    });

    testWidgets('the larger of the two margins wins', (tester) async {
      await _pump(tester, '- a\n\n## Head', spacing: _site);
      expect(
        _gapBetween(tester, _item(0), _heading('Head')),
        closeTo(36, 0.01),
      );

      await _pump(tester, '## Head\n\n- a', spacing: _site);
      expect(
        _gapBetween(tester, _heading('Head'), _item(0)),
        closeTo(12, 0.01),
      );
    });

    testWidgets('paragraphs are separated by the paragraph margin', (
      tester,
    ) async {
      await _pump(tester, 'one\n\ntwo', spacing: _site);
      // Two lines of text and the gap between them.
      expect(tester.getSize(_root).height, closeTo(24 + 16 + 24, 0.01));
    });

    testWidgets('text followed by a list on the next line is a paragraph', (
      tester,
    ) async {
      await _pump(tester, 'Steps:\n- a', spacing: _site);
      final top = tester.getTopLeft(_item(0)).dy - tester.getTopLeft(_root).dy;
      expect(top, closeTo(24 + 16, 0.01));
    });

    testWidgets('a zero margin puts blocks on consecutive lines', (
      tester,
    ) async {
      await _pump(tester, '- a\n\n> q', spacing: const BlockSpacing());
      expect(_gapBetween(tester, _item(0), _quote), closeTo(0, 0.01));
    });

    testWidgets('a block without a baseline gets exactly its margin', (
      tester,
    ) async {
      const spacing = BlockSpacing(
        hr: EdgeInsets.symmetric(vertical: 24),
        table: EdgeInsets.symmetric(vertical: 32),
        listItem: EdgeInsets.only(bottom: 4),
      );
      await _pump(tester, '- a\n\n---\n\n- b', spacing: spacing);
      final rule = find.byType(CustomDivider);
      expect(_gapBetween(tester, _item(0), rule), closeTo(24, 0.01));
      expect(_gapBetween(tester, rule, _item(1)), closeTo(24, 0.01));

      await _pump(
        tester,
        '- a\n\n| x |\n|---|\n| y |\n\n- b',
        spacing: spacing,
      );
      final table = find.byType(Table);
      expect(_gapBetween(tester, _item(0), table), closeTo(32, 0.01));
      expect(_gapBetween(tester, table, _item(1)), closeTo(32, 0.01));
    });

    testWidgets('nothing is added above the first block', (tester) async {
      await _pump(tester, '## Head\n\ntext', spacing: _site);
      expect(
        tester.getTopLeft(_heading('Head')).dy,
        closeTo(tester.getTopLeft(_root).dy, 0.01),
      );
    });

    testWidgets('without a spacing the blank line still separates blocks', (
      tester,
    ) async {
      await _pump(tester, 'one\n\ntwo');
      // The package's blank line: a line 1.15 times the font size.
      expect(tester.getSize(_root).height, closeTo(24 + 16 * 1.15 + 24, 0.5));
    });
  });
}
