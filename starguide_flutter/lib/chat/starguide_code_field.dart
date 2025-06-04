import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:starguide_flutter/main.dart';

/// A widget that displays code with syntax highlighting and a copy button.
///
/// The [StarguideCodeField] widget takes a [name] parameter which is displayed as a label
/// above the code block, and a [codes] parameter containing the actual code text
/// to display.
///
/// Features:
/// - Displays code in a Material container with rounded corners
/// - Shows the code language/name as a label
/// - Provides a copy button to copy code to clipboard
/// - Visual feedback when code is copied
/// - Themed colors that adapt to light/dark mode
class StarguideCodeField extends StatefulWidget {
  const StarguideCodeField(
      {super.key, required this.name, required this.codes});
  final String name;
  final String codes;

  @override
  State<StarguideCodeField> createState() => _StarguideCodeFieldState();
}

class _StarguideCodeFieldState extends State<StarguideCodeField> {
  bool _copied = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = theme.colorScheme.onInverseSurface.withAlpha(192);

    TextSpan formattedCodes;
    switch (widget.name) {
      case 'dart':
        formattedCodes = highlighterDart.highlight(widget.codes);
      case 'yaml':
        formattedCodes = highlighterYaml.highlight(widget.codes);
      case 'sql':
        formattedCodes = highlighterSql.highlight(widget.codes);
      default:
        formattedCodes = TextSpan(text: widget.codes);
    }
    formattedCodes = TextSpan(
      children: [
        formattedCodes,
      ],
      style: const TextStyle(
        fontFamily: 'JetBrainsMono',
        color: Colors.white,
        height: 1.5,
        fontSize: 13,
      ),
    );

    return Material(
      color: theme.colorScheme.inverseSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8,
                ),
                child: Text(
                  widget.name,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: labelColor,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  foregroundColor: labelColor,
                  backgroundColor: Colors.transparent,
                  textStyle: theme.textTheme.labelSmall?.copyWith(
                    color: labelColor,
                  ),
                ),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: widget.codes),
                  ).then((value) {
                    setState(() {
                      _copied = true;
                    });
                  });
                  await Future.delayed(const Duration(seconds: 2));
                  setState(() {
                    _copied = false;
                  });
                },
                icon: Icon(
                  (_copied) ? Icons.done : Icons.content_copy,
                  size: 16,
                ),
                label: Text((_copied) ? "Copied!" : "Copy"),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(
              top: 8,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: RichText(
              text: formattedCodes,
            ),
          ),
        ],
      ),
    );
  }
}
