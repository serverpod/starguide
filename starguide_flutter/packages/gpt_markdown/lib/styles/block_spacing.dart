import 'package:flutter/material.dart';

/// Vertical space around each kind of block, collapsed the way CSS collapses
/// margins.
///
/// Without a `BlockSpacing`, a blank line in the source is what separates two
/// blocks, and every blank line is the same height. Set one and the gap
/// between two blocks is instead the **larger** of the first block's bottom
/// margin and the second block's top margin — never their sum, and never
/// dependent on whether the source had a blank line between them. That is
/// how a browser spaces `p`, `h2`, `li` and `table`, so a style sheet written
/// from CSS carries over one value at a time:
///
/// ```dart
/// GptMarkdownStyleSheet(
///   spacing: BlockSpacing(
///     paragraph: EdgeInsets.only(bottom: 16),
///     h2: EdgeInsets.only(top: 36, bottom: 12),
///     listItem: EdgeInsets.only(bottom: 4),
///     list: EdgeInsets.only(bottom: 16),
///     table: EdgeInsets.symmetric(vertical: 32),
///   ),
/// )
/// ```
///
/// Only the top and bottom of each [EdgeInsets] are used. Every field is
/// optional and an unset field is zero, so the example above puts a 16 gap
/// between two paragraphs, a 36 gap before a heading (the heading's top wins
/// over the paragraph's bottom), 12 after it, and 4 between two items of a
/// list — with 16 after the last item, where the list's own bottom margin
/// takes over.
///
/// Nothing is added above the first block or below the last one.
///
/// A style on the widget wins over the theme **per field**, not per object.
@immutable
class BlockSpacing {
  /// Creates a BlockSpacing. Null fields defer to the theme, then to zero.
  const BlockSpacing({
    this.paragraph,
    this.h1,
    this.h2,
    this.h3,
    this.h4,
    this.h5,
    this.h6,
    this.list,
    this.listItem,
    this.table,
    this.codeBlock,
    this.blockQuote,
    this.hr,
  });

  /// Around a run of plain text — and around any block component this class
  /// does not know, such as one an app adds through `components`.
  final EdgeInsets? paragraph;

  /// Around a `#` heading.
  final EdgeInsets? h1;

  /// Around a `##` heading.
  final EdgeInsets? h2;

  /// Around a `###` heading.
  final EdgeInsets? h3;

  /// Around a `####` heading.
  final EdgeInsets? h4;

  /// Around a `#####` heading.
  final EdgeInsets? h5;

  /// Around a `######` heading.
  final EdgeInsets? h6;

  /// Around a whole list: a run of consecutive items of one kind. Collapses
  /// with the margins of the first and last item.
  final EdgeInsets? list;

  /// Around one item of a list — a bullet, a number, a checkbox or a radio.
  final EdgeInsets? listItem;

  /// Around a table.
  final EdgeInsets? table;

  /// Around a fenced code block.
  final EdgeInsets? codeBlock;

  /// Around a blockquote.
  final EdgeInsets? blockQuote;

  /// Around a horizontal rule.
  final EdgeInsets? hr;

  /// The margin of a heading of the given [level], 1 to 6.
  EdgeInsets? heading(int level) {
    return switch (level) {
      1 => h1,
      2 => h2,
      3 => h3,
      4 => h4,
      5 => h5,
      _ => h6,
    };
  }

  /// This spacing, with any unset field taken from [other], field by field.
  BlockSpacing merge(BlockSpacing? other) {
    if (other == null) {
      return this;
    }
    return BlockSpacing(
      paragraph: paragraph ?? other.paragraph,
      h1: h1 ?? other.h1,
      h2: h2 ?? other.h2,
      h3: h3 ?? other.h3,
      h4: h4 ?? other.h4,
      h5: h5 ?? other.h5,
      h6: h6 ?? other.h6,
      list: list ?? other.list,
      listItem: listItem ?? other.listItem,
      table: table ?? other.table,
      codeBlock: codeBlock ?? other.codeBlock,
      blockQuote: blockQuote ?? other.blockQuote,
      hr: hr ?? other.hr,
    );
  }

  /// This spacing with every unset field filled in as zero.
  ///
  /// Takes the scheme other styles resolve against so that all styles are
  /// resolved the same way; nothing here depends on colour.
  BlockSpacing resolve([ColorScheme? scheme]) {
    return BlockSpacing(
      paragraph: paragraph ?? EdgeInsets.zero,
      h1: h1 ?? EdgeInsets.zero,
      h2: h2 ?? EdgeInsets.zero,
      h3: h3 ?? EdgeInsets.zero,
      h4: h4 ?? EdgeInsets.zero,
      h5: h5 ?? EdgeInsets.zero,
      h6: h6 ?? EdgeInsets.zero,
      list: list ?? EdgeInsets.zero,
      listItem: listItem ?? EdgeInsets.zero,
      table: table ?? EdgeInsets.zero,
      codeBlock: codeBlock ?? EdgeInsets.zero,
      blockQuote: blockQuote ?? EdgeInsets.zero,
      hr: hr ?? EdgeInsets.zero,
    );
  }

  /// A copy with the given fields replaced.
  BlockSpacing copyWith({
    EdgeInsets? paragraph,
    EdgeInsets? h1,
    EdgeInsets? h2,
    EdgeInsets? h3,
    EdgeInsets? h4,
    EdgeInsets? h5,
    EdgeInsets? h6,
    EdgeInsets? list,
    EdgeInsets? listItem,
    EdgeInsets? table,
    EdgeInsets? codeBlock,
    EdgeInsets? blockQuote,
    EdgeInsets? hr,
  }) {
    return BlockSpacing(
      paragraph: paragraph ?? this.paragraph,
      h1: h1 ?? this.h1,
      h2: h2 ?? this.h2,
      h3: h3 ?? this.h3,
      h4: h4 ?? this.h4,
      h5: h5 ?? this.h5,
      h6: h6 ?? this.h6,
      list: list ?? this.list,
      listItem: listItem ?? this.listItem,
      table: table ?? this.table,
      codeBlock: codeBlock ?? this.codeBlock,
      blockQuote: blockQuote ?? this.blockQuote,
      hr: hr ?? this.hr,
    );
  }

  /// Linearly interpolates between two spacings.
  static BlockSpacing? lerp(BlockSpacing? a, BlockSpacing? b, double t) {
    if (a == null && b == null) {
      return null;
    }
    if (a == null) {
      return t < 0.5 ? null : b;
    }
    if (b == null) {
      return t < 0.5 ? a : null;
    }
    return BlockSpacing(
      paragraph: EdgeInsets.lerp(a.paragraph, b.paragraph, t),
      h1: EdgeInsets.lerp(a.h1, b.h1, t),
      h2: EdgeInsets.lerp(a.h2, b.h2, t),
      h3: EdgeInsets.lerp(a.h3, b.h3, t),
      h4: EdgeInsets.lerp(a.h4, b.h4, t),
      h5: EdgeInsets.lerp(a.h5, b.h5, t),
      h6: EdgeInsets.lerp(a.h6, b.h6, t),
      list: EdgeInsets.lerp(a.list, b.list, t),
      listItem: EdgeInsets.lerp(a.listItem, b.listItem, t),
      table: EdgeInsets.lerp(a.table, b.table, t),
      codeBlock: EdgeInsets.lerp(a.codeBlock, b.codeBlock, t),
      blockQuote: EdgeInsets.lerp(a.blockQuote, b.blockQuote, t),
      hr: EdgeInsets.lerp(a.hr, b.hr, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is BlockSpacing &&
        other.paragraph == paragraph &&
        other.h1 == h1 &&
        other.h2 == h2 &&
        other.h3 == h3 &&
        other.h4 == h4 &&
        other.h5 == h5 &&
        other.h6 == h6 &&
        other.list == list &&
        other.listItem == listItem &&
        other.table == table &&
        other.codeBlock == codeBlock &&
        other.blockQuote == blockQuote &&
        other.hr == hr;
  }

  @override
  int get hashCode => Object.hash(
    paragraph,
    h1,
    h2,
    h3,
    h4,
    h5,
    h6,
    list,
    listItem,
    table,
    codeBlock,
    blockQuote,
    hr,
  );
}
