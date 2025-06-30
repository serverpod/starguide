import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:provider/provider.dart';
import 'package:starguide_flutter/chat/starguide_code_field.dart';

/// A widget that displays a regular text message.
///
/// Supports markdown rendering via [GptMarkdown].
class StarguideTextMessage extends StatelessWidget {
  /// The text message data model.
  final TextMessage message;

  /// The index of the message in the list.
  final int index;

  /// Padding around the message bubble content.
  final EdgeInsetsGeometry? padding;

  /// Border radius of the message bubble.
  final BorderRadiusGeometry? borderRadius;

  /// Box constraints for the message bubble.
  final BoxConstraints? constraints;

  /// Font size for messages containing only emojis.
  final double? onlyEmojiFontSize;

  /// Background color for messages sent by the current user.
  final Color? sentBackgroundColor;

  /// Background color for messages received from other users.
  final Color? receivedBackgroundColor;

  /// Text style for messages sent by the current user.
  final TextStyle? sentTextStyle;

  /// Text style for messages received from other users.
  final TextStyle? receivedTextStyle;

  /// Text style for the message timestamp and status.
  final TextStyle? timeStyle;

  /// Whether to display the message timestamp.
  final bool showTime;

  /// Whether to display the message status (sent, delivered, seen) for sent messages.
  final bool showStatus;

  /// Position of the timestamp and status indicator relative to the text.
  final TimeAndStatusPosition timeAndStatusPosition;

  /// Insets for the timestamp and status indicator when [timeAndStatusPosition] is [TimeAndStatusPosition.inline].
  final EdgeInsetsGeometry? timeAndStatusPositionInlineInsets;

  /// The callback function to handle link clicks.
  final void Function(String url, String title)? onLinkTap;

  /// The position of the link preview widget relative to the text.
  /// If set to [LinkPreviewPosition.none], the link preview widget will not be displayed.
  /// A [LinkPreviewBuilder] must be provided for the preview to be displayed.
  final LinkPreviewPosition linkPreviewPosition;

  /// Creates a widget to display a text message.
  const StarguideTextMessage({
    super.key,
    required this.message,
    required this.index,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.borderRadius,
    this.constraints,
    this.onlyEmojiFontSize = 48,
    this.sentBackgroundColor,
    this.receivedBackgroundColor,
    this.sentTextStyle,
    this.receivedTextStyle,
    this.timeStyle,
    this.showTime = false,
    this.showStatus = false,
    this.timeAndStatusPosition = TimeAndStatusPosition.end,
    this.timeAndStatusPositionInlineInsets = const EdgeInsets.only(bottom: 2),
    this.onLinkTap,
    this.linkPreviewPosition = LinkPreviewPosition.bottom,
  });

  bool get _isOnlyEmoji => message.metadata?['isOnlyEmoji'] == true;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ChatTheme>();
    final isSentByMe = context.watch<UserID>() == message.authorId;
    final backgroundColor = _resolveBackgroundColor(isSentByMe, theme);
    final paragraphStyle = _resolveParagraphStyle(isSentByMe, theme);
    final timeStyle = _resolveTimeStyle(isSentByMe, theme);

    final timeAndStatus = showTime || (isSentByMe && showStatus)
        ? TimeAndStatus(
            time: message.createdAt,
            status: message.status,
            showTime: showTime,
            showStatus: isSentByMe && showStatus,
            textStyle: timeStyle,
          )
        : null;

    Widget content;
    if (message.text.isEmpty) {
      content = StarguideProgressIndicator();
    } else {
      final gptResponse = GptResponse(message.text);

      content = Column(
        crossAxisAlignment:
            isSentByMe ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
        children: [
          if (!isSentByMe) const SizedBox(width: double.infinity),
          GptMarkdown(
            gptResponse.text,
            style: _isOnlyEmoji
                ? paragraphStyle?.copyWith(fontSize: onlyEmojiFontSize)
                : paragraphStyle,
            onLinkTap: onLinkTap,
            codeBuilder: (context, name, codes, closed) => StarguideCodeField(
              name: name,
              codes: codes,
            ),
            highlightBuilder: (context, text, style) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade500.withAlpha(64),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  text,
                  style: style.copyWith(
                    fontFamily: 'JetBrainsMono',
                    fontSize: style.fontSize! * 0.9,
                  ),
                ),
              );
            },
          ),
          if (gptResponse.links.isNotEmpty)
            LinkPreviewList(links: gptResponse.links),
        ],
      );
    }

    final linkPreviewWidget = linkPreviewPosition != LinkPreviewPosition.none
        ? context.read<Builders>().linkPreviewBuilder?.call(
              context,
              message,
            )
        : null;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: isSentByMe
            ? (borderRadius ?? theme.shape)
            : BorderRadius.all(Radius.zero),
        child: Container(
          constraints: constraints,
          decoration: isSentByMe ? BoxDecoration(color: backgroundColor) : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (linkPreviewWidget != null &&
                  linkPreviewPosition == LinkPreviewPosition.top)
                linkPreviewWidget,
              Container(
                padding:
                    isSentByMe ? padding : EdgeInsets.symmetric(vertical: 16),
                child: _buildContentBasedOnPosition(
                  context: context,
                  textContent: content,
                  timeAndStatus: timeAndStatus,
                  paragraphStyle: paragraphStyle,
                ),
              ),
              if (linkPreviewWidget != null &&
                  linkPreviewPosition == LinkPreviewPosition.bottom)
                linkPreviewWidget,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentBasedOnPosition({
    required BuildContext context,
    required Widget textContent,
    TimeAndStatus? timeAndStatus,
    TextStyle? paragraphStyle,
  }) {
    if (timeAndStatus == null) {
      return textContent;
    }

    final textDirection = Directionality.of(context);

    switch (timeAndStatusPosition) {
      case TimeAndStatusPosition.start:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [textContent, timeAndStatus],
        );
      case TimeAndStatusPosition.inline:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(child: textContent),
            const SizedBox(width: 4),
            Padding(
              padding: timeAndStatusPositionInlineInsets ?? EdgeInsets.zero,
              child: timeAndStatus,
            ),
          ],
        );
      case TimeAndStatusPosition.end:
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: paragraphStyle?.lineHeight ?? 0),
              child: textContent,
            ),
            Opacity(opacity: 0, child: timeAndStatus),
            Positioned.directional(
              textDirection: textDirection,
              end: 0,
              bottom: 0,
              child: timeAndStatus,
            ),
          ],
        );
    }
  }

  Color? _resolveBackgroundColor(bool isSentByMe, ChatTheme theme) {
    if (isSentByMe) {
      return sentBackgroundColor ?? theme.colors.primary;
    }
    return receivedBackgroundColor ?? theme.colors.surfaceContainer;
  }

  TextStyle? _resolveParagraphStyle(bool isSentByMe, ChatTheme theme) {
    if (isSentByMe) {
      return sentTextStyle ??
          theme.typography.bodyMedium.copyWith(color: theme.colors.onPrimary);
    }
    return receivedTextStyle ??
        theme.typography.bodyMedium.copyWith(color: theme.colors.onSurface);
  }

  TextStyle? _resolveTimeStyle(bool isSentByMe, ChatTheme theme) {
    if (isSentByMe) {
      return timeStyle ??
          theme.typography.labelSmall.copyWith(
            color:
                _isOnlyEmoji ? theme.colors.onSurface : theme.colors.onPrimary,
          );
    }
    return timeStyle ??
        theme.typography.labelSmall.copyWith(color: theme.colors.onSurface);
  }
}

/// Internal extension for calculating the visual line height of a TextStyle.
extension on TextStyle {
  /// Calculates the line height based on the style's `height` and `fontSize`.
  double get lineHeight => (height ?? 1) * (fontSize ?? 0);
}

/// A widget to display the message timestamp and status indicator.
class TimeAndStatus extends StatelessWidget {
  /// The time the message was created.
  final DateTime? time;

  /// The status of the message.
  final MessageStatus? status;

  /// Whether to display the timestamp.
  final bool showTime;

  /// Whether to display the status indicator.
  final bool showStatus;

  /// The text style for the time and status.
  final TextStyle? textStyle;

  /// Creates a widget for displaying time and status.
  const TimeAndStatus({
    super.key,
    required this.time,
    this.status,
    this.showTime = true,
    this.showStatus = true,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = context.watch<DateFormat>();

    return Row(
      spacing: 2,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTime && time != null)
          Text(timeFormat.format(time!.toLocal()), style: textStyle),
        if (showStatus && status != null)
          if (status == MessageStatus.sending)
            SizedBox(
              width: 6,
              height: 6,
              child: CircularProgressIndicator(
                color: textStyle?.color,
                strokeWidth: 2,
              ),
            )
          else
            Icon(getIconForStatus(status!), color: textStyle?.color, size: 12),
      ],
    );
  }
}

class GptResponse {
  late final String text;
  late final List<GptResponseLink> links;

  GptResponse(String rawText) {
    final components = rawText.split('\n# References\n');

    if (components.isEmpty) {
      text = rawText;
      links = [];
    } else if (components.length == 1) {
      text = components[0];
      links = [];
    } else {
      text = components[0];
      final regex = RegExp(r'^\[([^\]]+)\]\(([^)]+)\)$');

      final rawLinks = components[1].split('\n');
      final parsedLinks = <GptResponseLink>[];

      for (var line in rawLinks) {
        line = line.trim();
        if (line.isEmpty) {
          continue;
        }

        final match = regex.firstMatch(line);
        if (match != null) {
          final text = match.group(1);
          final url = match.group(2);
          parsedLinks.add(GptResponseLink(url: Uri.parse(url!), title: text!));
        }
      }

      links = parsedLinks;
    }
  }
}

class GptResponseLink {
  final Uri url;
  final String title;

  GptResponseLink({required this.url, required this.title});
}

class LinkPreviewList extends StatelessWidget {
  final List<GptResponseLink> links;

  const LinkPreviewList({
    super.key,
    required this.links,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(
          'Answered based on the following references:',
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < links.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  LinkPreview(link: links[i]),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LinkPreview extends StatelessWidget {
  final GptResponseLink link;

  const LinkPreview({
    super.key,
    required this.link,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String domain = link.url.host;

    return SizedBox(
      width: 220,
      child: OutlinedButton(
        onPressed: () {
          print('Pressed');
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                link.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
              Text(
                domain,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.disabledColor),
                maxLines: 1,
                overflow: TextOverflow.clip,
                softWrap: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StarguideProgressIndicator extends StatelessWidget {
  const StarguideProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        spacing: 16,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Image.asset('assets/icon.webp'),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LinearProgressIndicator(
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                  minHeight: 6,
                ),
                const SizedBox(height: 16),
                Text(
                  'Generating response...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).disabledColor,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
