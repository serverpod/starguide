import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starguide_flutter/config/theme.dart';
import 'package:starguide_flutter/main.dart';
import 'package:starguide_flutter/widgets/starguide_markdown.dart';

/// A code block with syntax highlighting and a copy button.
///
/// Drawn like a code block on the Serverpod website: a dark, rounded box
/// with 24 px of padding around monospace text on a 1.6 line, in the colours
/// of VS Code's Dark+ theme. The language and the copy button sit in
/// the top right corner, where the website has nothing.
class StarguideCodeField extends StatefulWidget {
  const StarguideCodeField({
    super.key,
    required this.name,
    required this.codes,
  });

  /// The language of the code, as written after the opening fence.
  final String name;

  /// The code.
  final String codes;

  @override
  State<StarguideCodeField> createState() => _StarguideCodeFieldState();
}

class _StarguideCodeFieldState extends State<StarguideCodeField> {
  static const _background = Color(0xFF1E1E1E);
  static const _border = Color(0xFF444444);
  static const _text = Color(0xFFD4D4D4);
  static const _label = Color(0xFF9CA3AF);

  bool _copied = false;

  /// The code without the newline that closes the fence, which would
  /// otherwise draw as an empty last line.
  String get _code => widget.codes.trimRight();

  @override
  Widget build(BuildContext context) {
    final code = _code;
    TextSpan formattedCodes;
    switch (widget.name) {
      case 'dart':
        formattedCodes = highlighterDart.highlight(code);
      case 'yaml':
        formattedCodes = highlighterYaml.highlight(code);
      case 'sql':
        formattedCodes = highlighterSql.highlight(code);
      default:
        formattedCodes = TextSpan(text: code);
    }
    formattedCodes = TextSpan(
      children: [formattedCodes],
      style: const TextStyle(
        fontFamily: 'JetBrainsMono',
        color: _text,
        height: 1.6,
        fontSize: StarguideMarkdown.codeFontSize,
      ),
    );

    // A button replaces the ambient text style instead of merging with it,
    // so the family has to be named here.
    const labelStyle = TextStyle(
      fontFamily: kFontFamily,
      fontSize: 12,
      height: 1,
      color: _label,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _background,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(24),
              child: Text.rich(formattedCodes),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.name.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(widget.name, style: labelStyle),
                    ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      foregroundColor: _label,
                      backgroundColor: Colors.transparent,
                      textStyle: labelStyle,
                    ),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: code));
                      if (!mounted) return;
                      setState(() => _copied = true);
                      await Future.delayed(const Duration(seconds: 2));
                      if (!mounted) return;
                      setState(() => _copied = false);
                    },
                    icon: Icon(
                      _copied ? Icons.done : Icons.content_copy,
                      size: 14,
                    ),
                    label: Text(_copied ? 'Copied!' : 'Copy'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
