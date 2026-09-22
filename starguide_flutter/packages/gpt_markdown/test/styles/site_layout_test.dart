import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gpt_markdown/custom_widgets/unordered_ordered_list.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

/// Tests of the options that make tables, lists and inline code lay out the
/// way a browser lays them out.
Future<void> _pump(
  WidgetTester tester,
  String markdown, {
  GptMarkdownStyleSheet? styleSheet,
  InlineCodeStyle? inlineCodeStyle,
  double width = 400,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            child: GptMarkdown(
              markdown,
              style: const TextStyle(fontSize: 16),
              styleSheet: styleSheet,
              inlineCodeStyle: inlineCodeStyle,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

const _table = '| Name | Value |\n|---|---|\n| a | 1 |\n| bb | 22 |';

void main() {
  group('TableStyle', () {
    testWidgets('fillWidth stretches the table to the available width', (
      tester,
    ) async {
      await _pump(
        tester,
        _table,
        styleSheet: const GptMarkdownStyleSheet(
          table: TableStyle(fillWidth: true, borderWidth: 1),
        ),
      );
      // The grid sits inside the one-pixel outer border.
      expect(tester.getSize(find.byType(Table)).width, closeTo(398, 0.01));
    });

    testWidgets('without fillWidth the table is as wide as its content', (
      tester,
    ) async {
      await _pump(tester, _table);
      expect(tester.getSize(find.byType(Table)).width, lessThan(300));
    });

    testWidgets('verticalBorders false leaves no lines between columns', (
      tester,
    ) async {
      await _pump(
        tester,
        _table,
        styleSheet: const GptMarkdownStyleSheet(
          table: TableStyle(verticalBorders: false),
        ),
      );
      final border = tester.widget<Table>(find.byType(Table)).border!;
      expect(border.verticalInside, BorderSide.none);
      expect(border.horizontalInside, isNot(BorderSide.none));
    });

    testWidgets('header and body cells get their text styles', (tester) async {
      await _pump(
        tester,
        _table,
        styleSheet: const GptMarkdownStyleSheet(
          table: TableStyle(
            textStyle: TextStyle(fontSize: 15),
            headerTextStyle: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
      // The paragraph's own style is the ambient default; the cell's style
      // is on the span that holds the text.
      TextStyle? styleOf(String text) {
        final rich = tester.widget<RichText>(
          find.text(text, findRichText: true),
        );
        return rich.text
            .getSpanForPosition(const TextPosition(offset: 0))
            ?.style;
      }

      expect(styleOf('Name')?.fontWeight, FontWeight.w600);
      expect(styleOf('Name')?.fontSize, 15);
      expect(styleOf('bb')?.fontWeight, isNull);
      expect(styleOf('bb')?.fontSize, 15);
    });

    testWidgets('rowStripeColor fills every second body row', (tester) async {
      await _pump(
        tester,
        _table,
        styleSheet: const GptMarkdownStyleSheet(
          table: TableStyle(rowStripeColor: Color(0xFF123456)),
        ),
      );
      final rows = tester.widget<Table>(find.byType(Table)).children;
      expect(rows, hasLength(3));
      expect(rows[1].decoration, isNull);
      expect(
        (rows[2].decoration as BoxDecoration?)?.color,
        const Color(0xFF123456),
      );
    });
  });

  group('ListStyle', () {
    testWidgets('markerWidth aligns text in bullet and numbered lists', (
      tester,
    ) async {
      await _pump(
        tester,
        '- a\n\n1. b',
        styleSheet: const GptMarkdownStyleSheet(
          list: ListStyle(indent: 0, markerWidth: 17, gapAfterMarker: 7),
        ),
      );
      final bulletText = tester.getTopLeft(find.text('a', findRichText: true));
      final numberText = tester.getTopLeft(find.text('b', findRichText: true));
      final bullet = tester.getTopLeft(find.byType(UnorderedListView));
      // Text is placed to an eighth of a pixel.
      expect(bulletText.dx - bullet.dx, closeTo(24, 0.25));
      expect(numberText.dx, closeTo(bulletText.dx, 0.25));
    });

    testWidgets('nestedIndent indents an item written with leading spaces', (
      tester,
    ) async {
      await _pump(
        tester,
        '- a\n  - b\n        - c',
        styleSheet: const GptMarkdownStyleSheet(
          list: ListStyle(nestedIndent: 24),
        ),
      );
      final items = find.byType(UnorderedListView);
      expect(items, findsNWidgets(3));
      final first = tester.getTopLeft(items.at(0)).dx;
      expect(tester.getTopLeft(items.at(1)).dx - first, closeTo(24, 0.25));
      expect(tester.getTopLeft(items.at(2)).dx - first, closeTo(48, 0.25));
    });
  });

  group('InlineCodeStyle', () {
    Finder spacer(double width) => find.byWidgetPredicate(
      (w) => w is SizedBox && w.width == width && w.height == null,
    );

    testWidgets('horizontal padding takes space next to the code', (
      tester,
    ) async {
      await _pump(
        tester,
        'use `code` here',
        inlineCodeStyle: const InlineCodeStyle(
          padding: EdgeInsets.symmetric(horizontal: 6),
        ),
      );
      expect(spacer(6), findsNWidgets(2));
    });

    testWidgets('no space is taken without horizontal padding', (tester) async {
      await _pump(
        tester,
        'use `code` here',
        inlineCodeStyle: const InlineCodeStyle(
          padding: EdgeInsets.symmetric(vertical: 2),
        ),
      );
      expect(spacer(0), findsNothing);
    });

    testWidgets('code in a link label hugs its text', (tester) async {
      await _pump(
        tester,
        '[`code`](https://example.com)',
        inlineCodeStyle: const InlineCodeStyle(
          padding: EdgeInsets.symmetric(horizontal: 6),
        ),
      );
      expect(spacer(6), findsNothing);
    });
  });
}
