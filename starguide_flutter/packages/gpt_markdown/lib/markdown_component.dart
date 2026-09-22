part of 'gpt_markdown.dart';

/// The nesting context a [MarkdownComponent] is being rendered in.
///
/// Markdown nests: a link label may contain bold text, a table cell may
/// contain a link, a heading may contain inline code. A component declares the
/// contexts it is meaningful in through [MarkdownComponent.scopes] and is
/// skipped everywhere else.
///
/// This is what stops, for example, an app-specific `#channel` chip from also
/// rendering *inside* `[#channel](url)`. That produced a [WidgetSpan] nested
/// in the link's own [WidgetSpan], which does not paint on iOS.
enum MarkdownScope {
  /// Ordinary document or inline content. The default.
  content,

  /// Inside the `label` half of a `[label](url)` link.
  linkLabel,

  /// Inside a table cell.
  tableCell,

  /// Inside a `#` heading.
  heading,
}

/// Markdown components
abstract class MarkdownComponent {
  /// Every scope — the default value of [scopes].
  ///
  /// Declared `const` so reading [scopes] allocates nothing; it is read once
  /// per component per [generate] call, and [generate] recurses.
  static const Set<MarkdownScope> allScopes = {
    MarkdownScope.content,
    MarkdownScope.linkLabel,
    MarkdownScope.tableCell,
    MarkdownScope.heading,
  };

  /// Every scope except [MarkdownScope.linkLabel].
  ///
  /// The right default for anything rendering a [WidgetSpan]: a placeholder
  /// nested inside the link's own placeholder does not paint on iOS.
  static const Set<MarkdownScope> allScopesExceptLinkLabel = {
    MarkdownScope.content,
    MarkdownScope.tableCell,
    MarkdownScope.heading,
  };

  /// The nesting contexts this component is allowed to render in.
  ///
  /// Defaults to [allScopes], so existing components keep their behaviour.
  /// Override it to opt out of a context — most commonly
  /// [allScopesExceptLinkLabel].
  Set<MarkdownScope> get scopes => allScopes;

  /// The margin around this component's output when the style sheet sets a
  /// [BlockSpacing]. [text] is the matched source, for a component whose
  /// margin depends on it — a heading's depends on its level.
  ///
  /// Defaults to the paragraph margin, so a block component an app adds
  /// spaces like text.
  EdgeInsets blockMargin(BlockSpacing spacing, String text) =>
      spacing.paragraph ?? EdgeInsets.zero;

  /// The list this component's output is an item of, or null when it is not
  /// a list item.
  ///
  /// Consecutive items with the same group form one list: they are spaced
  /// with [BlockSpacing.listItem], and the list as a whole gets
  /// [BlockSpacing.list].
  Object? get listGroup => null;

  static List<MarkdownComponent> get globalComponents => [
    CodeBlockMd(),
    NewLines(),
    BlockQuote(),
    TableMd(),
    HTag(),
    UnOrderedList(),
    OrderedList(),
    RadioButtonMd(),
    CheckBoxMd(),
    HrLine(),
    IndentMd(),
  ];

  static final List<MarkdownComponent> inlineComponents = [
    ATagMd(),
    ImageMd(),
    AutolinkMd(),
    TableMd(),
    StrikeMd(),
    BoldMd(),
    ItalicMd(),
    UnderLineMd(),
    HighlightedText(),
    SourceTag(),
  ];

  /// Compiled combined regexes, keyed by the joined pattern string.
  ///
  /// Building and compiling the combined pattern is the most expensive part of
  /// [generate], and [generate] recurses once per nested span. The joined
  /// pattern string fully determines the [RegExp], so it is the natural key.
  static final Map<String, RegExp> _combinedRegexCache = {};

  /// Upper bound on [_combinedRegexCache].
  ///
  /// Components may be built from runtime data (a channel list, an emoji
  /// palette), so the set of distinct patterns is not bounded by the package.
  /// The cache is dropped wholesale rather than grown without limit.
  static const int _combinedRegexCacheLimit = 64;

  static RegExp _combinedRegexFor(List<MarkdownComponent> components) {
    final pattern = components.map<String>((e) => e.exp.pattern).join("|");
    // The combined regex carries one set of flags for every alternative, so a
    // single case-insensitive component makes the whole alternation
    // case-insensitive. Without this its matches never reach the dispatch loop
    // at all — the combined regex simply does not find them.
    final caseSensitive = components.every((e) => e.exp.isCaseSensitive);
    final key = caseSensitive ? pattern : 'i:$pattern';
    final cached = _combinedRegexCache[key];
    if (cached != null) {
      return cached;
    }
    if (_combinedRegexCache.length >= _combinedRegexCacheLimit) {
      _combinedRegexCache.clear();
    }
    return _combinedRegexCache[key] = RegExp(
      pattern,
      multiLine: true,
      dotAll: true,
      caseSensitive: caseSensitive,
    );
  }

  /// Generate widget for markdown widget
  static List<InlineSpan> generate(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
    bool includeGlobalComponents,
  ) {
    var components =
        includeGlobalComponents
            ? config.components ?? MarkdownComponent.globalComponents
            : config.inlineComponents ?? MarkdownComponent.inlineComponents;

    // Consumer patterns are matched ahead of the built-ins, and only in the
    // inline pass. The global pass resolves block structure (headings, lists,
    // tables); everything it does not claim comes straight back here with
    // [includeGlobalComponents] false, so inline patterns still see all of it.
    final inlinePatterns = config.inlinePatterns;
    if (!includeGlobalComponents &&
        inlinePatterns != null &&
        inlinePatterns.isNotEmpty) {
      components = [...inlinePatterns.map(InlinePatternMd.new), ...components];
    }

    // Filter *before* the combined regex is built, not just in the dispatch
    // loop below. Filtering only the dispatch loop would leave the combined
    // regex claiming text that no component then handles.
    final scope = config.scope;
    components = components
        .where((e) => e.scopes.contains(scope))
        .toList(growable: false);

    List<InlineSpan> spans = [];
    if (components.isEmpty) {
      // An empty pattern matches everywhere and would consume the text.
      return [TextSpan(text: text, style: config.style)];
    }
    // With a `BlockSpacing`, the blank lines of the source are no longer what
    // separates blocks. Every span is recorded with the component that made
    // it, and the gaps are computed afterwards from the neighbours' margins.
    final spacing =
        includeGlobalComponents
            ? resolvedStyleSheet(context, config).spacing?.resolve()
            : null;
    final entries = <_BlockEntry>[];
    final combinedRegex = _combinedRegexFor(components);
    text.splitMapJoin(
      combinedRegex,
      onMatch: (p0) {
        String element = p0[0] ?? "";
        for (var each in components) {
          var p = each.exp.pattern;
          // The group matters: `^a|b$` anchors only the first and last
          // alternative, so any component whose pattern has a top-level `|`
          // would claim matches it does not actually cover.
          var exp = RegExp(
            '^(?:$p)\$',
            multiLine: each.exp.isMultiLine,
            dotAll: each.exp.isDotAll,
            caseSensitive: each.exp.isCaseSensitive,
          );
          if (exp.hasMatch(element)) {
            final span = each.span(context, element, config);
            spans.add(span);
            entries.add(_BlockEntry(span, component: each, text: element));
            return "";
          }
        }
        // The combined regex matched but no single component claims the whole
        // match. Show the source text rather than dropping it silently.
        assert(() {
          debugPrint(
            'gpt_markdown: no component claimed "$element"; '
            'rendering it as plain text.',
          );
          return true;
        }());
        final span = TextSpan(text: element, style: config.style);
        spans.add(span);
        entries.add(_BlockEntry(span));
        return "";
      },
      onNonMatch: (p0) {
        if (p0.isEmpty) {
          return "";
        }
        if (includeGlobalComponents) {
          var run = p0;
          if (spacing != null) {
            // A newline next to a block only separated it from this text in
            // the source. The gap is computed from the margins instead.
            if (run.startsWith('\n')) {
              run = run.substring(1);
            }
            if (run.endsWith('\n')) {
              run = run.substring(0, run.length - 1);
            }
            if (run.trim().isEmpty) {
              return "";
            }
          }
          var newSpans = generate(context, run, config.copyWith(), false);
          spans.addAll(newSpans);
          entries.add(_BlockEntry(TextSpan(children: newSpans)));
          return "";
        }
        spans.add(TextSpan(text: p0, style: config.style));
        return "";
      },
    );

    if (spacing == null) {
      return spans;
    }
    return _spaceBlocks(entries, spacing);
  }

  /// Joins the blocks of one pass with the gaps their margins ask for.
  ///
  /// The gap between two blocks is the larger of the first one's bottom
  /// margin and the second one's top margin, as CSS collapses margins. The
  /// margins of a list wrap those of its first and last items.
  static List<InlineSpan> _spaceBlocks(
    List<_BlockEntry> entries,
    BlockSpacing spacing,
  ) {
    final result = <InlineSpan>[];
    _BlockEntry? previous;
    for (final entry in entries) {
      if (entry.component is NewLines) {
        // The blank line itself is only what told the source apart.
        continue;
      }
      if (previous != null) {
        result.add(_gapSpan(_gapBetween(previous, entry, spacing)));
      }
      result.add(entry.span);
      previous = entry;
    }
    return result;
  }

  static double _gapBetween(
    _BlockEntry above,
    _BlockEntry below,
    BlockSpacing spacing,
  ) {
    var bottom = above.margin(spacing).bottom;
    var top = below.margin(spacing).top;
    final list = spacing.list ?? EdgeInsets.zero;
    final sameList =
        above.listGroup != null && above.listGroup == below.listGroup;
    if (above.listGroup != null && !sameList) {
      bottom = max(bottom, list.bottom);
    }
    if (below.listGroup != null && !sameList) {
      top = max(top, list.top);
    }
    return max(bottom, top);
  }

  /// Ends the current line without adding to its height.
  static const _lineBreak = TextSpan(
    text: '\n',
    style: TextStyle(fontSize: 0, height: 0),
  );

  /// A line break followed by an empty line exactly [gap] tall.
  ///
  /// A line that holds only a newline is as tall as that newline's font, so
  /// the gap is a font size — which also keeps it selectable and copyable as
  /// the blank line it stands for.
  static InlineSpan _gapSpan(double gap) {
    if (gap <= 0) {
      return _lineBreak;
    }
    return TextSpan(
      children: [
        _lineBreak,
        TextSpan(text: '\n', style: TextStyle(fontSize: gap, height: 1)),
      ],
    );
  }

  InlineSpan span(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  );

  RegExp get exp;
  bool get inline;
}

/// One span the global pass produced, with what produced it, so the gaps
/// between blocks can be computed once all of them are known.
class _BlockEntry {
  _BlockEntry(this.span, {this.component, this.text = ''});

  final InlineSpan span;

  /// The component that matched, or null for a run of plain text.
  final MarkdownComponent? component;

  /// The matched source.
  final String text;

  EdgeInsets margin(BlockSpacing spacing) =>
      component?.blockMargin(spacing, text) ??
      spacing.paragraph ??
      EdgeInsets.zero;

  Object? get listGroup => component?.listGroup;
}

/// Inline component
abstract class InlineMd extends MarkdownComponent {
  @override
  bool get inline => true;

  @override
  InlineSpan span(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  );
}

/// Block component
abstract class BlockMd extends MarkdownComponent {
  @override
  bool get inline => false;

  @override
  RegExp get exp =>
      RegExp(r'^\ *?' + expString + r"$", dotAll: true, multiLine: true);

  String get expString;

  @override
  InlineSpan span(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    var matches = RegExp(r'^(?<spaces>\ \ +).*').firstMatch(text);
    var spaces = matches?.namedGroup('spaces');
    var length = spaces?.length ?? 0;
    var child = build(context, text, config);
    final nestedIndent =
        length == 0
            ? null
            : (resolvedStyleSheet(context, config).list ?? const ListStyle())
                .nestedIndent;
    if (nestedIndent != null) {
      // Two spaces nest an item under a bullet, three under a number and
      // four under either, so anything up to four is one level. Every four
      // more is one level deeper.
      final depth = 1 + (length - 2) ~/ 4;
      child = Directionality(
        textDirection: config.textDirection,
        child: Padding(
          padding: EdgeInsetsDirectional.only(start: nestedIndent * depth),
          child: child,
        ),
      );
    } else {
      length = min(length, 4);
      if (length > 0) {
        child = UnorderedListView(
          spacing: length * 1.0,
          textDirection: config.textDirection,
          child: child,
        );
      }
    }
    child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [Flexible(child: child)],
    );
    return scaledWidgetSpan(child: child, config: config);
  }

  Widget build(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  );
}

/// Indent component
class IndentMd extends BlockMd {
  @override
  String get expString => (r"^(\ \ +)([^\n]+)$");
  @override
  Widget build(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    var match = this.exp.firstMatch(text);
    var conf = config.copyWith();
    return Directionality(
      textDirection: config.textDirection,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: config.getRich(
              TextSpan(
                children: MarkdownComponent.generate(
                  context,
                  match?[2]?.trim() ?? "",
                  conf,
                  false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Heading component
class HTag extends BlockMd {
  @override
  String get expString => (r"(?<hash>#{1,6})\ (?<data>[^\n]+?)$");

  @override
  EdgeInsets blockMargin(BlockSpacing spacing, String text) {
    final hashes = RegExp(r'^\s*(#{1,6})\s').firstMatch(text)?[1];
    return spacing.heading(hashes?.length ?? 1) ?? EdgeInsets.zero;
  }

  @override
  Widget build(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    var theme = GptMarkdownTheme.of(context);
    var match = this.exp.firstMatch(text.trim());
    final hashes = match?.namedGroup('hash');
    final level = hashes == null ? 1 : hashes.length;
    final headingStyle = (resolvedStyleSheet(context, config).heading ??
            const HeadingStyle())
        .resolve(Theme.of(context).colorScheme);
    final levelStyle =
        [theme.h1, theme.h2, theme.h3, theme.h4, theme.h5, theme.h6][level - 1];
    final override = headingStyle.textStyle;
    var conf = config.copyWith(
      scope: MarkdownScope.heading,
      style:
          override == null
              ? levelStyle
              : (levelStyle ?? const TextStyle()).merge(override),
    );
    final headingDividerPadding = headingStyle.dividerPadding;
    final headingPadding = headingStyle.padding;

    final headingBuilder = config.headingBuilder;
    if (headingBuilder != null) {
      final content = config.getRich(
        TextSpan(
          children: MarkdownComponent.generate(
            context,
            "${match?.namedGroup('data')}",
            conf,
            false,
          ),
        ),
      );
      return headingBuilder(context, level, content, headingStyle);
    }

    final rich = config.getRich(
      TextSpan(
        children: [
          ...(MarkdownComponent.generate(
            context,
            "${match?.namedGroup('data')}",
            conf,
            false,
          )),
          if (level == 1 &&
              (headingStyle.showDivider ??
                  theme.autoAddDividerLineAfterH1)) ...[
            const TextSpan(
              text: "\n ",
              style: TextStyle(fontSize: 0, height: 0),
            ),
            // Left uncompensated on purpose. The rule is a one-pixel
            // decoration with no text in it, so the paragraph scaling its box
            // is invisible — and compensating it made the space it takes at 1x
            // differ from every other scale.
            WidgetSpan(
              child: CustomDivider(
                height: headingStyle.dividerThickness ?? theme.hrLineThickness,
                color: headingStyle.dividerColor ?? theme.hrLineColor,
                padding:
                    headingDividerPadding is EdgeInsets
                        ? headingDividerPadding
                        : theme.hrLinePadding,
              ),
            ),
          ],
        ],
      ),
    );
    if (headingPadding == null) {
      return rich;
    }
    return Padding(padding: headingPadding, child: rich);
  }
}

class NewLines extends InlineMd {
  @override
  RegExp get exp => RegExp(r"\n\n+");
  @override
  InlineSpan span(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    return TextSpan(
      text: "\n\n",
      style: TextStyle(
        fontSize: config.style?.fontSize ?? 14,
        height: 1.15,
        color: config.style?.color,
      ),
    );
  }
}

/// Horizontal line component
class HrLine extends BlockMd {
  @override
  String get expString => (r"⸻|((--)[-]+)$");

  @override
  EdgeInsets blockMargin(BlockSpacing spacing, String text) =>
      spacing.hr ?? EdgeInsets.zero;
  @override
  Widget build(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    final gptTheme = GptMarkdownTheme.of(context);
    final style = (resolvedStyleSheet(context, config).hr ?? const HrStyle())
        .resolve(Theme.of(context).colorScheme);
    final builder = config.hrBuilder;
    if (builder != null) {
      return builder(context, style);
    }
    final padding = style.padding;
    return CustomDivider(
      height: style.thickness ?? gptTheme.hrLineThickness,
      color: style.color ?? gptTheme.hrLineColor,
      padding: padding is EdgeInsets ? padding : gptTheme.hrLinePadding,
    );
  }
}

/// Checkbox component
class CheckBoxMd extends BlockMd {
  @override
  String get expString => (r"\[((?:\x|\ ))\]\ (\S[^\n]*?)$");

  @override
  EdgeInsets blockMargin(BlockSpacing spacing, String text) =>
      spacing.listItem ?? EdgeInsets.zero;

  @override
  Object? get listGroup => CheckBoxMd;

  @override
  Widget build(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    var match = this.exp.firstMatch(text.trim());
    final style = (resolvedStyleSheet(context, config).checkbox ??
            const CheckboxStyle())
        .resolve(Theme.of(context).colorScheme);
    final checked = "${match?[1]}" == "x";
    final label = MdWidget(context, "${match?[2]}", false, config: config);
    final builder = config.checkboxBuilder;
    if (builder != null) {
      return builder(context, checked, label, style);
    }
    return CustomCb(
      value: checked,
      textDirection: config.textDirection,
      spacing: style.gapAfterBox ?? 5,
      style: style,
      onChanged: config.onCheckboxChanged,
      child: label,
    );
  }
}

/// Radio Button component
class RadioButtonMd extends BlockMd {
  @override
  String get expString => (r"\(((?:\x|\ ))\)\ (\S[^\n]*)$");

  @override
  EdgeInsets blockMargin(BlockSpacing spacing, String text) =>
      spacing.listItem ?? EdgeInsets.zero;

  @override
  Object? get listGroup => RadioButtonMd;

  @override
  Widget build(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    var match = this.exp.firstMatch(text.trim());
    final style = (resolvedStyleSheet(context, config).checkbox ??
            const CheckboxStyle())
        .resolve(Theme.of(context).colorScheme);
    final selected = "${match?[1]}" == "x";
    final label = MdWidget(context, "${match?[2]}", false, config: config);
    final builder = config.radioOptionBuilder;
    if (builder != null) {
      return builder(context, selected, label, style);
    }
    return CustomRb(
      value: selected,
      textDirection: config.textDirection,
      spacing: style.gapAfterBox ?? 5,
      style: style,
      onChanged: config.onCheckboxChanged,
      child: label,
    );
  }
}

/// Block quote component
class BlockQuote extends InlineMd {
  @override
  bool get inline => false;

  @override
  EdgeInsets blockMargin(BlockSpacing spacing, String text) =>
      spacing.blockQuote ?? EdgeInsets.zero;

  @override
  RegExp get exp =>
  // RegExp(r"(?<=\n\n)(\ +)(.+?)(?=\n\n)", dotAll: true, multiLine: true);
  RegExp(
    r"(?:(?:^)\ *>[^\n]+)(?:(?:\n)\ *>[^\n]+)*",
    dotAll: true,
    multiLine: true,
  );

  @override
  InlineSpan span(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    var match = exp.firstMatch(text);
    var dataBuilder = StringBuffer();
    var m = match?[0] ?? '';
    for (var each in m.split('\n')) {
      if (each.startsWith(RegExp(r'\ *>'))) {
        var subString = each.trimLeft().substring(1);
        if (subString.startsWith(' ')) {
          subString = subString.substring(1);
        }
        dataBuilder.writeln(subString);
      } else {
        dataBuilder.writeln(each);
      }
    }
    var data = dataBuilder.toString().trim();
    var quotedConfig = config;
    final style = (resolvedStyleSheet(context, config).blockQuote ??
            const BlockQuoteStyle())
        .resolve(Theme.of(context).colorScheme);
    final textStyle = style.textStyle;
    if (textStyle != null) {
      final base = config.style;
      quotedConfig = config.copyWith(
        style: base == null ? textStyle : base.merge(textStyle),
      );
    }
    // The style sits on the span as well as on its leaves, so a block inside
    // the quote — a list, say — is scaled like the text around it.
    final content = quotedConfig.getRich(
      TextSpan(
        children: MarkdownComponent.generate(context, data, quotedConfig, true),
        style: quotedConfig.style,
      ),
      paragraphStyle: blockParagraphStyle(context, quotedConfig),
    );

    final builder = config.blockQuoteBuilder;
    final Widget quote;
    if (builder == null) {
      quote = _defaultQuote(context, content, style, config.textDirection);
    } else {
      quote = builder(context, content, style);
    }

    return TextSpan(
      children: [
        scaledWidgetSpan(
          config: config,
          alignment: PlaceholderAlignment.bottom,
          baseline: null,
          child: quote,
        ),
      ],
    );
  }

  Widget _defaultQuote(
    BuildContext context,
    Widget content,
    BlockQuoteStyle style,
    TextDirection direction,
  ) {
    final padding = style.padding;
    final margin = style.margin;
    final background = style.backgroundColor;
    final barColor = style.barColor;
    final barWidth = style.barWidth;

    Widget child = content;
    if (padding != null) {
      child = Padding(padding: padding, child: child);
    }
    child = BlockQuoteWidget(
      color: barColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
      direction: direction,
      width: barWidth ?? 3,
      child: child,
    );
    if (background != null) {
      final radius = style.barRadius;
      child = DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: radius == null ? null : BorderRadius.all(radius),
        ),
        child: child,
      );
    }
    if (margin != null) {
      child = Padding(padding: margin, child: child);
    }
    return Directionality(textDirection: direction, child: child);
  }
}

/// Unordered list component
class UnOrderedList extends BlockMd {
  @override
  String get expString => (r"(?:\-|\*)\ ([^\n]+)$");

  @override
  EdgeInsets blockMargin(BlockSpacing spacing, String text) =>
      spacing.listItem ?? EdgeInsets.zero;

  @override
  Object? get listGroup => UnOrderedList;

  @override
  Widget build(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    var match = this.exp.firstMatch(text);

    var child = MdWidget(context, "${match?[1]?.trim()}", true, config: config);

    return config.unOrderedListBuilder?.call(
          context,
          child,
          config.copyWith(),
        ) ??
        _unorderedListView(context, config, child);
  }

  Widget _unorderedListView(
    BuildContext context,
    GptMarkdownConfig config,
    Widget child,
  ) {
    final style = (resolvedStyleSheet(context, config).list ??
            const ListStyle())
        .resolve(Theme.of(context).colorScheme);
    final fontSize =
        config.style?.fontSize ??
        DefaultTextStyle.of(context).style.fontSize ??
        kDefaultFontSize;
    return UnorderedListView(
      bulletColor:
          style.bulletColor ??
          config.style?.color ??
          DefaultTextStyle.of(context).style.color,
      padding: style.indent ?? 7,
      spacing: style.gapAfterMarker ?? 10,
      bulletSize: style.bulletSize ?? 0.3 * fontSize,
      markerWidth: style.markerWidth,
      textDirection: config.textDirection,
      child: child,
    );
  }
}

/// Ordered list component
class OrderedList extends BlockMd {
  @override
  String get expString => (r"([0-9]+)\.\ ([^\n]+)$");

  @override
  EdgeInsets blockMargin(BlockSpacing spacing, String text) =>
      spacing.listItem ?? EdgeInsets.zero;

  @override
  Object? get listGroup => OrderedList;

  @override
  Widget build(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    var match = this.exp.firstMatch(text);

    var no = "${match?[1]}".trim();

    var child = MdWidget(context, "${match?[2]}".trim(), true, config: config);
    return config.orderedListBuilder?.call(
          context,
          no,
          child,
          config.copyWith(),
        ) ??
        _orderedListView(context, config, no, child);
  }

  Widget _orderedListView(
    BuildContext context,
    GptMarkdownConfig config,
    String no,
    Widget child,
  ) {
    final style = (resolvedStyleSheet(context, config).list ??
            const ListStyle())
        .resolve(Theme.of(context).colorScheme);
    final marker = style.markerTextStyle;
    final base = (config.style ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w100,
    );
    return OrderedListView(
      no: "$no.",
      textDirection: config.textDirection,
      style: marker == null ? base : base.merge(marker),
      // 6 is what `OrderedListView` used before this was configurable; the
      // bullet list uses different numbers, so neither is a shared default.
      padding: style.indent ?? 6,
      spacing: style.gapAfterMarker ?? 6,
      markerWidth: style.markerWidth,
      child: child,
    );
  }
}

class HighlightedText extends InlineMd {
  @override
  RegExp get exp => RegExp(r"`(?!`)(.+?)(?<!`)`(?!`)");

  @override
  InlineSpan span(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    var match = exp.firstMatch(text.trim());
    var highlightedText = match?[1] ?? "";

    // A plain TextSpan, tagged so the paragraph paints a rounded chip behind
    // it — see `custom_widgets/inline_code.dart`. Keeping it out of a
    // WidgetSpan is what lets inline code wrap across lines, stay selectable,
    // sit on the surrounding baseline, and appear inside a link label.
    final codeStyle = (config.inlineCodeStyle ??
            GptMarkdownTheme.of(context).inlineCode)
        .resolve(Theme.of(context).colorScheme);
    final textStyle = codeStyle.applyTo(config.style ?? const TextStyle());

    final builder = config.inlineCodeBuilder;
    if (builder != null) {
      return builder(context, highlightedText, textStyle, codeStyle);
    }

    // ignore: deprecated_member_use_from_same_package
    final legacyBuilder = config.highlightBuilder;
    if (legacyBuilder != null) {
      // Kept so 1.1.x code compiles. Wrapped on the baseline rather than at
      // the old hardcoded `PlaceholderAlignment.middle`, which sat visibly off
      // the surrounding text.
      return baselineWidgetSpan(
        legacyBuilder(context, highlightedText, config.style ?? textStyle),
      );
    }

    final span = CodeTextSpan(
      text: highlightedText,
      codeStyle: codeStyle,
      style: textStyle,
    );
    final padding = codeStyle.padding ?? EdgeInsets.zero;
    // Horizontal padding is real space. The chip is painted that far past
    // the text, and without something holding that space it would sit over
    // the neighbouring words. A placeholder nested in a link label does not
    // paint on iOS, so a chip in a label hugs its text instead.
    if ((padding.left <= 0 && padding.right <= 0) ||
        config.scope == MarkdownScope.linkLabel) {
      return span;
    }
    return TextSpan(
      children: [
        if (padding.left > 0) WidgetSpan(child: SizedBox(width: padding.left)),
        span,
        if (padding.right > 0)
          WidgetSpan(child: SizedBox(width: padding.right)),
      ],
    );
  }
}

/// Bold text component
class BoldMd extends InlineMd {
  @override
  RegExp get exp =>
      RegExp(r"(?<!\*)\*\*(?<!\s)(.+?)(?<!\s)\*\*(?!\*)", dotAll: true);

  @override
  InlineSpan span(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    var match = exp.firstMatch(text.trim());
    var conf = config.copyWith(
      style:
          config.style?.copyWith(fontWeight: FontWeight.bold) ??
          const TextStyle(fontWeight: FontWeight.bold),
    );
    return TextSpan(
      children: MarkdownComponent.generate(
        context,
        "${match?[1]}",
        conf,
        false,
      ),
      style: conf.style,
    );
  }
}

class StrikeMd extends InlineMd {
  @override
  RegExp get exp => RegExp(r"(?<!\*)\~\~(?<!\s)(.+?)(?<!\s)\~\~(?!\*)");

  @override
  InlineSpan span(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    var match = exp.firstMatch(text.trim());
    var conf = config.copyWith(
      style:
          config.style?.copyWith(
            decoration: TextDecoration.lineThrough,
            decorationColor: config.style?.color,
          ) ??
          const TextStyle(decoration: TextDecoration.lineThrough),
    );
    return TextSpan(
      children: MarkdownComponent.generate(
        context,
        "${match?[1]}",
        conf,
        false,
      ),
      style: conf.style,
    );
  }
}

/// Italic text component
class ItalicMd extends InlineMd {
  @override
  RegExp get exp =>
      RegExp(r"(?:(?<!\*)\*(?<!\s)(.+?)(?<!\s)\*(?!\*))", dotAll: true);

  @override
  InlineSpan span(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    var match = exp.firstMatch(text.trim());
    var data = match?[1] ?? match?[2];
    var conf = config.copyWith(
      style: (config.style ?? const TextStyle()).copyWith(
        fontStyle: FontStyle.italic,
      ),
    );
    return TextSpan(
      children: MarkdownComponent.generate(context, "$data", conf, false),
      style: conf.style,
    );
  }
}

/// source text component
class SourceTag extends InlineMd {
  @override
  RegExp get exp => RegExp(r"(?:【.*?)?\[(\d+?)\]");

  @override
  InlineSpan span(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    var match = exp.firstMatch(text.trim());
    var content = match?[1];
    if (content == null) {
      return const TextSpan();
    }
    final style = (resolvedStyleSheet(context, config).sourceTag ??
            const SourceTagStyle())
        .resolve(Theme.of(context).colorScheme);
    final size = style.size ?? 20;
    Widget chip =
        config.sourceTagBuilder?.call(
          context,
          content,
          style.textStyle ?? const TextStyle(),
        ) ??
        SizedBox(
          width: size,
          height: size,
          child: Material(
            color:
                style.backgroundColor ??
                Theme.of(context).colorScheme.onInverseSurface,
            shape:
                style.shape == BoxShape.rectangle
                    ? const RoundedRectangleBorder()
                    : const OvalBorder(),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                content,
                style: style.textStyle,
                textDirection: config.textDirection,
              ),
            ),
          ),
        );

    final onTap = config.onSourceTagTap;
    if (onTap != null) {
      chip = GestureDetector(onTap: () => onTap(content), child: chip);
    }

    return scaledWidgetSpan(
      config: config,
      alignment: PlaceholderAlignment.middle,
      baseline: null,
      child: Padding(
        padding: style.padding ?? const EdgeInsets.all(2),
        child: chip,
      ),
    );
  }
}

/// Link text component
class ATagMd extends InlineMd {
  @override
  RegExp get exp => RegExp(r"(?<!\!)\[.*?\]\([^\s]*\)");

  /// CommonMark forbids links inside link labels, and the label is rendered
  /// inside this component's own [WidgetSpan] — a second one nested in it does
  /// not paint on iOS.
  @override
  Set<MarkdownScope> get scopes => MarkdownComponent.allScopesExceptLinkLabel;

  @override
  InlineSpan span(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    var bracketCount = 0;
    var start = 1;
    var end = 0;
    for (var i = 0; i < text.length; i++) {
      if (text[i] == '[') {
        bracketCount++;
      } else if (text[i] == ']') {
        bracketCount--;
        if (bracketCount == 0) {
          end = i;
          break;
        }
      }
    }

    if (end + 1 >= text.length || text[end + 1] != '(') {
      // Malformed link. Show the source text instead of deleting it.
      return TextSpan(text: text, style: config.style);
    }

    // First try to find the basic pattern
    // final basicMatch = RegExp(r'(?<!\!)\[(.*)\]\(').firstMatch(text.trim());
    // if (basicMatch == null) {
    //   return const TextSpan();
    // }

    final linkText = text.substring(start, end);
    final urlStart = end + 2;

    // Now find the balanced closing parenthesis
    int parenCount = 0;
    int urlEnd = urlStart;

    for (int i = urlStart; i < text.length; i++) {
      final char = text[i];

      if (char == '(') {
        parenCount++;
      } else if (char == ')') {
        if (parenCount == 0) {
          // This is the closing parenthesis of the link
          urlEnd = i;
          break;
        } else {
          parenCount--;
        }
      }
    }

    if (urlEnd == urlStart) {
      // No closing parenthesis found. Show the source text instead of
      // deleting it.
      return TextSpan(text: text, style: config.style);
    }

    final url = text.substring(urlStart, urlEnd).trim();

    var ending = text.substring(urlEnd + 1);

    var endingSpans = MarkdownComponent.generate(
      context,
      ending,
      config,
      false,
    );

    final child = buildLinkSpan(context, config, url: url, label: linkText);
    var textSpan = TextSpan(children: [child, ...endingSpans]);
    return textSpan;
  }
}

/// The style sheet in force: the widget's, merged over the theme's, field by
/// field, with anything still unset resolved to the package default.
///
/// Kept in one place so every component resolves its style the same way and a
/// widget override never discards the rest of the theme.
GptMarkdownStyleSheet resolvedStyleSheet(
  BuildContext context,
  GptMarkdownConfig config,
) {
  final widgetSheet = config.styleSheet ?? const GptMarkdownStyleSheet();
  return widgetSheet.merge(GptMarkdownTheme.of(context).styleSheet);
}

/// The style of a paragraph that can hold blocks, or null to leave it to the
/// ambient [DefaultTextStyle].
///
/// Every line of a paragraph is at least as tall as the paragraph's own
/// font, above and below the baseline, whatever is on the line. That floor
/// is what puts a few pixels of air around a block that is shorter than a
/// line of text, or has no baseline — a rule, a table. With a `BlockSpacing`
/// in force the gaps are drawn as lines of their own, so the paragraph is
/// given a font of size zero and each block's line is exactly the block. The
/// text keeps its size because [GptMarkdownConfig.style] sets one; without
/// that, the floor has to stay, or the text would inherit the zero.
///
/// Without a `BlockSpacing` the paragraph keeps the ambient style, so
/// nothing moves.
TextStyle? blockParagraphStyle(BuildContext context, GptMarkdownConfig config) {
  if (config.style?.fontSize == null ||
      resolvedStyleSheet(context, config).spacing == null) {
    return null;
  }
  return const TextStyle(fontSize: 0);
}

/// A [WidgetSpan] for an inline widget.
///
/// Note for anyone touching text scaling: a paragraph lays inline children out
/// in *scaled* space — it divides their constraints by the scale factor and
/// multiplies the reported size back. At a 3x setting a block widget is
/// therefore given a third of the width, wraps into a narrow column and
/// reserves far more height than it needs. Compensating for that inside the
/// child was tried and produced overlapping text; the fix belongs in how
/// blocks are composed, not in a wrapper. See CHANGELOG.
WidgetSpan scaledWidgetSpan({
  required Widget child,
  required GptMarkdownConfig config,
  PlaceholderAlignment alignment = PlaceholderAlignment.baseline,
  TextBaseline? baseline = TextBaseline.alphabetic,
}) {
  return WidgetSpan(alignment: alignment, baseline: baseline, child: child);
}

/// Builds the span for a link, shared by [ATagMd] and [AutolinkMd].
///
/// [label] is rendered through [MarkdownComponent.generate] in the
/// [MarkdownScope.linkLabel] scope when [parseLabel] is true. Autolinks pass
/// false: their label *is* the URL, and running it back through the inline
/// components would let `ItalicMd` eat the underscores out of a path such as
/// `https://example.com/a_b_c`.
InlineSpan buildLinkSpan(
  BuildContext context,
  GptMarkdownConfig config, {
  required String url,
  required String label,
  bool parseLabel = true,
}) {
  final theme = GptMarkdownTheme.of(context);
  final linkStyleSpec = (resolvedStyleSheet(context, config).link ??
          const LinkStyle())
      .resolve(Theme.of(context).colorScheme);
  final baseColor = linkStyleSpec.color ?? theme.linkColor;
  final hoverColor = linkStyleSpec.hoverColor ?? theme.linkHoverColor;
  final decoration = linkStyleSpec.decoration ?? TextDecoration.underline;
  final builder = config.linkBuilder;

  List<InlineSpan> labelSpans(TextStyle style) {
    if (!parseLabel) {
      return [TextSpan(text: label, style: style)];
    }
    return MarkdownComponent.generate(
      context,
      label,
      config.copyWith(style: style, scope: MarkdownScope.linkLabel),
      false,
    );
  }

  if (builder != null) {
    // Build a styled span to hand off to the custom linkBuilder.
    final linkStyle = (config.style ?? const TextStyle()).copyWith(
      color: baseColor,
      decorationColor: baseColor,
      decoration: decoration,
      decorationThickness: linkStyleSpec.decorationThickness,
      fontWeight: linkStyleSpec.fontWeight,
    );
    return scaledWidgetSpan(
      config: config,
      child: GestureDetector(
        onTap: () => config.onLinkTap?.call(url, label),
        child: builder(
          context,
          TextSpan(children: labelSpans(linkStyle), style: linkStyle),
          url,
          config.style ?? const TextStyle(),
        ),
      ),
    );
  }

  // Default rendering — LinkButton rebuilds the span on every hover change so
  // bold/italic text inside a link also picks up the hover colour.
  return scaledWidgetSpan(
    config: config,
    child: LinkButton(
      hoverColor: hoverColor,
      color: baseColor,
      onPressed: () => config.onLinkTap?.call(url, label),
      text: label,
      config: config,
      spanBuilder: (color) {
        final spanStyle = (config.style ?? const TextStyle()).copyWith(
          color: color,
          decorationColor: color,
          decoration: decoration,
          decorationThickness: linkStyleSpec.decorationThickness,
          fontWeight: linkStyleSpec.fontWeight,
        );
        return TextSpan(children: labelSpans(spanStyle), style: spanStyle);
      },
    ),
  );
}

/// Image component
class ImageMd extends InlineMd {
  @override
  RegExp get exp => RegExp(r"\!\[[^\[\]]*\]\([^\s]*\)");

  /// An image is not meaningful as a link label, and nesting its [WidgetSpan]
  /// inside the link's own one does not paint on iOS.
  @override
  Set<MarkdownScope> get scopes => MarkdownComponent.allScopesExceptLinkLabel;

  @override
  InlineSpan span(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    // First try to find the basic pattern
    final basicMatch = RegExp(r'\!\[([^\[\]]*)\]\(').firstMatch(text.trim());
    if (basicMatch == null) {
      return const TextSpan();
    }

    final altText = basicMatch.group(1) ?? '';
    final urlStart = basicMatch.end;

    // Now find the balanced closing parenthesis
    int parenCount = 0;
    int urlEnd = urlStart;

    for (int i = urlStart; i < text.length; i++) {
      final char = text[i];

      if (char == '(') {
        parenCount++;
      } else if (char == ')') {
        if (parenCount == 0) {
          // This is the closing parenthesis of the image
          urlEnd = i;
          break;
        } else {
          parenCount--;
        }
      }
    }

    if (urlEnd == urlStart) {
      // No closing parenthesis found
      return const TextSpan();
    }

    final url = text.substring(urlStart, urlEnd).trim();

    double? height;
    double? width;
    if (altText.isNotEmpty) {
      var size = RegExp(r"^([0-9]+)?x?([0-9]+)?").firstMatch(altText.trim());
      width = double.tryParse(size?[1]?.toString().trim() ?? 'a');
      height = double.tryParse(size?[2]?.toString().trim() ?? 'a');
    }

    final Widget image;
    if (config.imageBuilder != null) {
      image = config.imageBuilder!(context, url, width, height);
    } else {
      image = SizedBox(
        width: width,
        height: height,
        child: Image(
          image: NetworkImage(url),
          loadingBuilder: (
            BuildContext context,
            Widget child,
            ImageChunkEvent? loadingProgress,
          ) {
            if (loadingProgress == null) {
              return child;
            }
            return CustomImageLoading(
              progress:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : 1,
            );
          },
          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) {
            return const CustomImageError();
          },
        ),
      );
    }
    final imageStyle = (resolvedStyleSheet(context, config).image ??
            const ImageStyle())
        .resolve(Theme.of(context).colorScheme);
    Widget decorated = image;
    final imageRadius = imageStyle.borderRadius;
    if (imageRadius != null) {
      decorated = ClipRRect(
        borderRadius: BorderRadius.all(imageRadius),
        child: decorated,
      );
    }
    final imagePadding = imageStyle.padding;
    if (imagePadding != null) {
      decorated = Padding(padding: imagePadding, child: decorated);
    }
    final onImageTap = config.onImageTap;
    if (onImageTap != null) {
      decorated = GestureDetector(
        onTap: () => onImageTap(url),
        child: decorated,
      );
    }
    return scaledWidgetSpan(
      config: config,
      alignment: PlaceholderAlignment.bottom,
      baseline: null,
      child: decorated,
    );
  }
}

/// Table component
class TableMd extends BlockMd {
  /// A table cannot be a link label.
  @override
  Set<MarkdownScope> get scopes => MarkdownComponent.allScopesExceptLinkLabel;

  @override
  EdgeInsets blockMargin(BlockSpacing spacing, String text) =>
      spacing.table ?? EdgeInsets.zero;

  @override
  String get expString =>
      (r"(((\|[^\n\|]+\|)((([^\n\|]+\|)+)?)\ *)(\n\ *(((\|[^\n\|]+\|)(([^\n\|]+\|)+)?))\ *)+)$");
  @override
  Widget build(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    final tableStyle = (resolvedStyleSheet(context, config).table ??
            const TableStyle())
        .resolve(Theme.of(context).colorScheme);
    final tableRadius = tableStyle.borderRadius;
    final List<Map<int, String>> value =
        text
            .split('\n')
            .map<Map<int, String>>(
              (e) =>
                  e
                      .trim()
                      .split('|')
                      .where((element) => element.isNotEmpty)
                      .toList()
                      .asMap(),
            )
            .toList();

    // Check if table has a header and separator row
    bool hasHeader = value.length >= 2;
    List<TextAlign> columnAlignments = [];

    if (hasHeader) {
      // Parse alignment from the separator row (second row)
      var separatorRow = value[1];
      columnAlignments = List.generate(separatorRow.length, (index) {
        String separator = separatorRow[index] ?? "";
        separator = separator.trim();

        // Check for alignment indicators
        bool hasLeftColon = separator.startsWith(':');
        bool hasRightColon = separator.endsWith(':');

        if (hasLeftColon && hasRightColon) {
          return TextAlign.center;
        } else if (hasRightColon) {
          return TextAlign.right;
        } else if (hasLeftColon) {
          return TextAlign.left;
        } else {
          return TextAlign.left; // Default alignment
        }
      });
    }

    int maxCol = 0;
    for (final each in value) {
      if (maxCol < each.keys.length) {
        maxCol = each.keys.length;
      }
    }

    if (maxCol == 0) {
      return Text("", style: config.style);
    }

    // Ensure we have alignment for all columns
    while (columnAlignments.length < maxCol) {
      columnAlignments.add(TextAlign.left);
    }

    var tableBuilder = config.tableBuilder;

    if (tableBuilder != null) {
      var customTable =
          List<CustomTableRow?>.generate(value.length, (index) {
            var isHeader = index == 0;
            var row = value[index];
            if (row.isEmpty) {
              return null;
            }
            if (index == 1) {
              return null;
            }
            var fields = List<CustomTableField>.generate(maxCol, (index) {
              var field = row[index];
              return CustomTableField(
                data: field ?? "",
                alignment: columnAlignments[index],
              );
            });
            return CustomTableRow(isHeader: isHeader, fields: fields);
          }).nonNulls.toList();
      return tableBuilder(
        context,
        customTable,
        config.style ?? const TextStyle(),
        config,
      );
    }

    final scheme = Theme.of(context).colorScheme;
    final cellPadding =
        tableStyle.cellPadding ??
        const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    final cellStyle = tableStyle.textStyle;
    final bodyStyle =
        cellStyle == null
            ? config.style
            : (config.style ?? const TextStyle()).merge(cellStyle);
    final headerStyle = tableStyle.headerTextStyle;
    final headStyle =
        headerStyle == null
            ? bodyStyle
            : (bodyStyle ?? const TextStyle()).merge(headerStyle);
    final stripe = tableStyle.rowStripeColor;

    final rows =
        value
            .asMap()
            .entries
            .where((entry) {
              // Skip the separator row (second row) from rendering
              if (hasHeader && entry.key == 1) {
                return false;
              }
              return true;
            })
            .map<TableRow>((entry) {
              final isHeader = hasHeader && entry.key == 0;
              // Body rows count from the first one after the header, so
              // stripes alternate from the second body row.
              final bodyIndex = hasHeader ? entry.key - 2 : entry.key;
              final Color? fill;
              if (isHeader) {
                fill =
                    tableStyle.headerBackground ??
                    scheme.surfaceContainerHighest;
              } else if (stripe != null && bodyIndex.isOdd) {
                fill = stripe;
              } else {
                fill = null;
              }
              return TableRow(
                decoration: fill == null ? null : BoxDecoration(color: fill),
                children: List.generate(maxCol, (index) {
                  var e = entry.value;
                  String data = e[index] ?? "";
                  if (RegExp(r"^:?--+:?$").hasMatch(data.trim()) ||
                      data.trim().isEmpty) {
                    return const SizedBox();
                  }

                  // Apply alignment based on column alignment
                  Widget content = Padding(
                    padding: cellPadding,
                    child: MdWidget(
                      context,
                      (e[index] ?? "").trim(),
                      false,
                      config: config.copyWith(
                        scope: MarkdownScope.tableCell,
                        style: isHeader ? headStyle : bodyStyle,
                      ),
                    ),
                  );

                  // Wrap with alignment widget
                  switch (columnAlignments[index]) {
                    case TextAlign.center:
                      content = Center(child: content);
                      break;
                    case TextAlign.right:
                      content = Align(
                        alignment: Alignment.centerRight,
                        child: content,
                      );
                      break;
                    case TextAlign.left:
                    default:
                      content = Align(
                        alignment: Alignment.centerLeft,
                        child: content,
                      );
                      break;
                  }

                  return content;
                }),
              );
            })
            .toList();

    final borderWidth = tableStyle.borderWidth ?? 1;
    final borderColor = tableStyle.borderColor ?? scheme.onSurface;
    final borderRadius =
        tableRadius == null ? BorderRadius.zero : BorderRadius.all(tableRadius);
    final verticalAlignment =
        tableStyle.verticalAlignment ?? TableCellVerticalAlignment.middle;
    final verticalBorders = tableStyle.verticalBorders ?? true;
    final fillWidth = tableStyle.fillWidth ?? false;

    final Widget table;
    if (verticalBorders && !fillWidth) {
      table = Table(
        textDirection: config.textDirection,
        defaultColumnWidth: CustomTableColumnWidth(),
        defaultVerticalAlignment: verticalAlignment,
        border: TableBorder.all(
          width: borderWidth,
          color: borderColor,
          borderRadius: borderRadius,
        ),
        children: rows,
      );
    } else {
      // `TableBorder` only rounds a border that is the same on every edge,
      // inside lines included. So the grid draws just the lines between
      // cells, and the outer border is drawn around it, with the header fill
      // clipped to the border's inner curve.
      final side = BorderSide(width: borderWidth, color: borderColor);
      final innerRadius =
          tableRadius == null
              ? BorderRadius.zero
              : BorderRadius.all(
                Radius.elliptical(
                  max(0, tableRadius.x - borderWidth),
                  max(0, tableRadius.y - borderWidth),
                ),
              );
      table = Container(
        decoration: BoxDecoration(
          border: Border.fromBorderSide(side),
          borderRadius: borderRadius,
        ),
        child: ClipRRect(
          borderRadius: innerRadius,
          child: Table(
            textDirection: config.textDirection,
            defaultColumnWidth:
                fillWidth
                    ? const ProportionalColumnWidth()
                    : CustomTableColumnWidth(),
            defaultVerticalAlignment: verticalAlignment,
            border: TableBorder(
              horizontalInside: side,
              verticalInside: verticalBorders ? side : BorderSide.none,
            ),
            children: rows,
          ),
        ),
      );
    }

    final controller = ScrollController();
    Widget scrolling(Widget child) {
      return Scrollbar(
        controller: controller,
        child: SingleChildScrollView(
          controller: controller,
          scrollDirection: Axis.horizontal,
          child: child,
        ),
      );
    }

    if (!fillWidth) {
      return scrolling(table);
    }
    // The scroll view offers unbounded width, so the width to fill is read
    // outside it. The table then only grows past that width, and scrolls,
    // when a cell holds something that cannot wrap.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth) {
          return scrolling(table);
        }
        return scrolling(FitWidth(width: constraints.maxWidth, child: table));
      },
    );
  }
}

class CodeBlockMd extends BlockMd {
  @override
  String get expString => r"```(.*?)\n((.*?)(:?\n\s*?```)|(.*)(:?\n```)?)$";

  @override
  EdgeInsets blockMargin(BlockSpacing spacing, String text) =>
      spacing.codeBlock ?? EdgeInsets.zero;
  @override
  Widget build(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    String codes = this.exp.firstMatch(text)?[2] ?? "";
    String name = this.exp.firstMatch(text)?[1] ?? "";
    codes = codes.replaceAll(r"```", "");
    bool closed = text.endsWith("```");

    final style = (resolvedStyleSheet(context, config).codeBlock ??
            const CodeBlockStyle())
        .resolve(Theme.of(context).colorScheme);
    return config.codeBuilder?.call(context, name, codes, closed) ??
        CodeField(
          name: name,
          codes: codes,
          style: style,
          onCopy: config.onCodeCopy,
        );
  }
}

class UnderLineMd extends InlineMd {
  @override
  RegExp get exp =>
      RegExp(r"<u>(.*?)(?:</u>|$)", multiLine: true, dotAll: true);

  @override
  InlineSpan span(
    BuildContext context,
    String text,
    final GptMarkdownConfig config,
  ) {
    var match = exp.firstMatch(text.trim());
    var conf = config.copyWith(
      style: (config.style ?? const TextStyle()).copyWith(
        decoration: TextDecoration.underline,
        decorationColor: config.style?.color,
      ),
    );
    return TextSpan(
      children: MarkdownComponent.generate(
        context,
        "${match?[1]}",
        conf,
        false,
      ),
      style: conf.style,
    );
  }
}

class CustomTableField {
  final String data;
  final TextAlign alignment;

  CustomTableField({required this.data, this.alignment = TextAlign.left});
}

class CustomTableRow {
  final bool isHeader;
  final List<CustomTableField> fields;

  CustomTableRow({this.isHeader = false, required this.fields});
}
