import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:starguide_flutter/chat/starguide_code_field.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders Markdown the way the Serverpod website renders it, so an answer
/// reads like a page on serverpod.dev.
///
/// The values are those of the website's `.blog-content` stylesheet, in
/// units of [fontSize], the body size, where the website has 16 px. The font
/// is the app's, Inter, where the website uses the system font of the
/// visitor's device, which a Flutter web app cannot load.
class StarguideMarkdown extends StatelessWidget {
  const StarguideMarkdown(this.data, {super.key, this.style, this.onLinkTap});

  /// The Markdown to render.
  final String data;

  /// The style of body text. Defaults to [bodyStyle].
  final TextStyle? style;

  /// Called with a tapped link. Defaults to opening the link.
  final void Function(String url, String title)? onLinkTap;

  // The website's greys, from Tailwind's palette.
  static const _text = Color(0xFF1F2937);
  static const _muted = Color(0xFF6B7280);
  static const _cellText = Color(0xFF374151);
  static const _headerText = Color(0xFF111827);
  static const _headerFill = Color(0xFFF9FAFB);
  static const _border = Color(0xFFE5E7EB);
  static const _codeFill = Color(0xFFF3F4F6);
  static const _link = Color(0xFF6366F1);
  static const _linkHover = Color(0xFF4F46E5);

  /// The body size, which every other size and space is a multiple of. A
  /// notch below the website's 16 px.
  static const fontSize = 15.0;

  /// Body text on a 1.7 line, with the leading split evenly above and below
  /// the glyphs as a browser does.
  static const bodyStyle = TextStyle(
    fontSize: fontSize,
    height: 1.7,
    fontWeight: FontWeight.w400,
    color: _text,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// A heading of [size] ems: bold, in the body colour, on the body's 1.7
  /// line. The website styles four levels; the last two get the body size.
  static TextStyle _heading(double size) => TextStyle(
    fontSize: size * fontSize,
    height: 1.7,
    fontWeight: FontWeight.w700,
    color: _text,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// A heading's margin: 1.5 em above and 0.5 em below, in its own size.
  static EdgeInsets _headingMargin(double size) => EdgeInsets.only(
    top: 1.5 * size * fontSize,
    bottom: 0.5 * size * fontSize,
  );

  static final _spacing = BlockSpacing(
    paragraph: const EdgeInsets.only(bottom: fontSize),
    h1: _headingMargin(1.875),
    h2: _headingMargin(1.5),
    h3: _headingMargin(1.25),
    h4: _headingMargin(1.125),
    h5: _headingMargin(1),
    h6: _headingMargin(1),
    list: const EdgeInsets.only(bottom: fontSize),
    listItem: const EdgeInsets.only(bottom: 0.25 * fontSize),
    table: const EdgeInsets.symmetric(vertical: 2 * fontSize),
    codeBlock: const EdgeInsets.symmetric(vertical: fontSize),
    blockQuote: const EdgeInsets.symmetric(vertical: fontSize),
    hr: const EdgeInsets.symmetric(vertical: 1.5 * fontSize),
  );

  static final _styleSheet = GptMarkdownStyleSheet(
    spacing: _spacing,
    heading: const HeadingStyle(showDivider: false),
    link: const LinkStyle(
      color: _link,
      hoverColor: _linkHover,
      decoration: TextDecoration.underline,
    ),
    // Text starts 1.5 em in, as with the website's list padding. The marker
    // sits at the end of a box, so a bullet and a number line up, with a
    // browser's gap before the text.
    list: const ListStyle(
      indent: 0,
      markerWidth: 1.0625 * fontSize,
      gapAfterMarker: 0.4375 * fontSize,
      bulletSize: 0.3 * fontSize,
      nestedIndent: 1.5 * fontSize,
      markerTextStyle: TextStyle(fontWeight: FontWeight.w400),
    ),
    table: const TableStyle(
      borderColor: _border,
      borderWidth: 1,
      borderRadius: Radius.circular(8),
      cellPadding: EdgeInsets.symmetric(
        horizontal: fontSize,
        vertical: 0.75 * fontSize,
      ),
      headerBackground: _headerFill,
      headerTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: _headerText,
      ),
      textStyle: TextStyle(
        fontSize: 0.9375 * fontSize,
        height: 1.6,
        color: _cellText,
      ),
      verticalBorders: false,
      fillWidth: true,
      verticalAlignment: TableCellVerticalAlignment.top,
    ),
    blockQuote: const BlockQuoteStyle(
      barWidth: 4,
      barColor: _border,
      padding: EdgeInsetsDirectional.only(start: fontSize),
      margin: EdgeInsets.zero,
      textStyle: TextStyle(color: _muted),
    ),
    hr: const HrStyle(thickness: 1, color: _border),
  );

  /// The size of code, inline and in blocks: seven eighths of the text.
  static const codeFontSize = 0.875 * fontSize;

  /// Inline code on a grey chip padded by 0.4 em sideways and 0.2 em
  /// vertically, in its own size, in the code font.
  static const _inlineCode = InlineCodeStyle(
    fontFamily: 'JetBrainsMono',
    fontSizeFactor: 0.875,
    color: _text,
    backgroundColor: _codeFill,
    borderColor: Colors.transparent,
    borderWidth: 0,
    borderRadius: Radius.circular(4),
    padding: EdgeInsets.symmetric(
      horizontal: 0.4 * codeFontSize,
      vertical: 0.2 * codeFontSize,
    ),
  );

  static final _theme = GptMarkdownThemeData(
    brightness: Brightness.light,
    h1: _heading(1.875),
    h2: _heading(1.5),
    h3: _heading(1.25),
    h4: _heading(1.125),
    h5: _heading(1),
    h6: _heading(1),
    hrLineThickness: 1,
    hrLineColor: _border,
    linkColor: _link,
    linkHoverColor: _linkHover,
    autoAddDividerLineAfterH1: false,
    inlineCode: _inlineCode,
    styleSheet: _styleSheet,
  );

  @override
  Widget build(BuildContext context) {
    return GptMarkdownTheme(
      gptThemeData: _theme,
      child: GptMarkdown(
        data,
        style: style ?? bodyStyle,
        onLinkTap: onLinkTap ?? (url, title) => launchUrl(Uri.parse(url)),
        codeBuilder: (context, name, codes, closed) =>
            StarguideCodeField(name: name, codes: codes),
      ),
    );
  }
}
