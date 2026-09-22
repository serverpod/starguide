import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:starguide_flutter/chat/starguide_code_field.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders Markdown the way the Serverpod website renders it, so an answer
/// reads like a page on serverpod.dev.
///
/// The values are those of the website's `.blog-content` stylesheet, with an
/// em taken as the 16 px body size. The font is the app's, Inter, where the
/// website uses the system font of the visitor's device, which a Flutter web
/// app cannot load.
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

  /// Body text: 16 px on a 1.7 line, with the leading split evenly above and
  /// below the glyphs as a browser does.
  static const bodyStyle = TextStyle(
    fontSize: 16,
    height: 1.7,
    fontWeight: FontWeight.w400,
    color: _text,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// A heading: bold, in the body colour, on the body's 1.7 line. The
  /// website styles four levels; the last two are given the body size.
  static TextStyle _heading(double size) => TextStyle(
    fontSize: size,
    height: 1.7,
    fontWeight: FontWeight.w700,
    color: _text,
    letterSpacing: 0,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// A heading's margin: 1.5 em above and 0.5 em below, in its own size.
  static EdgeInsets _headingMargin(double size) =>
      EdgeInsets.only(top: 1.5 * size, bottom: 0.5 * size);

  static final _spacing = BlockSpacing(
    paragraph: const EdgeInsets.only(bottom: 16),
    h1: _headingMargin(30),
    h2: _headingMargin(24),
    h3: _headingMargin(20),
    h4: _headingMargin(18),
    h5: _headingMargin(16),
    h6: _headingMargin(16),
    list: const EdgeInsets.only(bottom: 16),
    listItem: const EdgeInsets.only(bottom: 4),
    table: const EdgeInsets.symmetric(vertical: 32),
    codeBlock: const EdgeInsets.symmetric(vertical: 16),
    blockQuote: const EdgeInsets.symmetric(vertical: 16),
    hr: const EdgeInsets.symmetric(vertical: 24),
  );

  static final _styleSheet = GptMarkdownStyleSheet(
    spacing: _spacing,
    heading: const HeadingStyle(showDivider: false),
    link: const LinkStyle(
      color: _link,
      hoverColor: _linkHover,
      decoration: TextDecoration.underline,
    ),
    // Text starts 24 px in, as with the website's 1.5 em list padding. The
    // marker sits at the end of a 17 px box, so a bullet and a number line
    // up, with a browser's gap before the text.
    list: const ListStyle(
      indent: 0,
      markerWidth: 17,
      gapAfterMarker: 7,
      bulletSize: 5,
      nestedIndent: 24,
      markerTextStyle: TextStyle(fontWeight: FontWeight.w400),
    ),
    table: const TableStyle(
      borderColor: _border,
      borderWidth: 1,
      borderRadius: Radius.circular(8),
      cellPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      headerBackground: _headerFill,
      headerTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: _headerText,
      ),
      textStyle: TextStyle(fontSize: 15, height: 1.6, color: _cellText),
      verticalBorders: false,
      fillWidth: true,
      verticalAlignment: TableCellVerticalAlignment.top,
    ),
    blockQuote: const BlockQuoteStyle(
      barWidth: 4,
      barColor: _border,
      padding: EdgeInsetsDirectional.only(start: 16),
      margin: EdgeInsets.zero,
      textStyle: TextStyle(color: _muted),
    ),
    hr: const HrStyle(thickness: 1, color: _border),
  );

  /// Inline code: seven eighths of the text size, on a grey chip padded by
  /// 0.4 em sideways and 0.2 em vertically, in the code font.
  static const _inlineCode = InlineCodeStyle(
    fontFamily: 'JetBrainsMono',
    fontSizeFactor: 0.875,
    color: _text,
    backgroundColor: _codeFill,
    borderColor: Colors.transparent,
    borderWidth: 0,
    borderRadius: Radius.circular(4),
    padding: EdgeInsets.symmetric(horizontal: 5.6, vertical: 2.8),
  );

  static final _theme = GptMarkdownThemeData(
    brightness: Brightness.light,
    h1: _heading(30),
    h2: _heading(24),
    h3: _heading(20),
    h4: _heading(18),
    h5: _heading(16),
    h6: _heading(16),
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
