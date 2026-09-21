import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:shad/shad.dart';
import 'package:starguide_client/starguide_client.dart';
import 'package:starguide_flutter/admin/admin_format.dart';
import 'package:starguide_flutter/admin/widgets/admin_widgets.dart';
import 'package:starguide_flutter/main.dart';

/// Opens a side sheet with the full conversation of a chat session.
void showConversationSheet(
  BuildContext context,
  AdminChatSessionSummary summary,
) {
  showShadSheet<void>(
    context: context,
    side: ShadSheetSide.right,
    builder: (context) => ConversationSheet(summary: summary),
  );
}

/// A table of chat sessions with their vote and Jev's judgement.
class ChatSessionsTable extends StatelessWidget {
  const ChatSessionsTable({
    super.key,
    required this.sessions,
    required this.onTap,
    this.emptyMessage = 'No conversations match the filter.',
  });

  final List<AdminChatSessionSummary> sessions;
  final ValueChanged<AdminChatSessionSummary> onTap;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return AdminTableCard(
      emptyMessage: emptyMessage,
      onRowTap: (row) => onTap(sessions[row]),
      columnWidths: const [150, null, 100, 130, 130, 110],
      minFlexibleWidth: 280,
      header: const [
        ShadTableCell.header(child: Text('Started')),
        ShadTableCell.header(child: Text('First question')),
        ShadTableCell.header(
          alignment: Alignment.centerRight,
          child: Text('Messages'),
        ),
        ShadTableCell.header(child: Text('Vote')),
        ShadTableCell.header(child: Text('Outcome')),
        ShadTableCell.header(child: Text('User')),
      ],
      rows: [
        for (final session in sessions)
          [
            ShadTableCell(
              child: ShadTooltip(
                builder: (context) => Text(
                  formatDateTime(session.createdAt),
                  style: theme.textTheme.small,
                ),
                child: Text(formatRelative(session.createdAt)),
              ),
            ),
            ShadTableCell(
              child: Text(
                session.firstQuestion.isEmpty
                    ? '(no question asked)'
                    : session.firstQuestion.replaceAll('\n', ' '),
                overflow: TextOverflow.ellipsis,
                style: session.firstQuestion.isEmpty
                    ? theme.textTheme.muted
                    : null,
              ),
            ),
            ShadTableCell(
              alignment: Alignment.centerRight,
              child: Text('${session.messageCount}'),
            ),
            ShadTableCell(child: VoteBadge(goodAnswer: session.goodAnswer)),
            ShadTableCell(
              child: AnswerOutcomeBadge(
                outcome: session.answerOutcome,
                confidence: session.answerOutcomeConfidence,
              ),
            ),
            ShadTableCell(
              child: Text(
                session.authUserId == null ? 'Anonymous' : 'Signed in',
                style: theme.textTheme.muted,
              ),
            ),
          ],
      ],
    );
  }
}

/// A side sheet with the full conversation of a chat session.
class ConversationSheet extends StatefulWidget {
  const ConversationSheet({super.key, required this.summary});

  final AdminChatSessionSummary summary;

  @override
  State<ConversationSheet> createState() => _ConversationSheetState();
}

class _ConversationSheetState extends State<ConversationSheet> {
  late Future<AdminChatSessionDetail> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = client.admin.getChatSession(widget.summary.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final summary = widget.summary;

    return ShadSheet(
      constraints: const BoxConstraints(maxWidth: 760),
      title: Text('Conversation ${summary.id}'),
      description: Text(
        'Started ${formatDateTime(summary.createdAt)} '
        '(${formatRelative(summary.createdAt)})',
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          spacing: 16,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                VoteBadge(goodAnswer: summary.goodAnswer),
                AnswerOutcomeBadge(
                  outcome: summary.answerOutcome,
                  confidence: summary.answerOutcomeConfidence,
                ),
                ShadBadge.outline(
                  child: Text(
                    summary.authUserId == null ? 'Anonymous' : 'Signed in',
                  ),
                ),
              ],
            ),
            AdminAsyncContent<AdminChatSessionDetail>(
              future: _future,
              onRetry: _load,
              builder: (context, detail) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  if (detail.messages.isEmpty)
                    Text(
                      'No messages were stored for this session.',
                      style: theme.textTheme.muted,
                    ),
                  for (final message in detail.messages)
                    _MessageBubble(message: message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final isUser = message.type == ChatMessageType.user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Row(
          spacing: 6,
          children: [
            Icon(
              isUser ? LucideIcons.user : LucideIcons.sparkles,
              size: 14,
              color: theme.colorScheme.mutedForeground,
            ),
            Text(isUser ? 'Question' : 'Answer', style: theme.textTheme.muted),
          ],
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUser ? theme.colorScheme.muted : theme.colorScheme.card,
            border: Border.all(color: theme.colorScheme.border),
            borderRadius: theme.radii.md,
          ),
          child: isUser
              ? SelectableText(message.message, style: theme.textTheme.p)
              : MarkdownBlock(
                  data: message.message,
                  selectable: true,
                  config: MarkdownConfig(
                    configs: [
                      PConfig(textStyle: theme.textTheme.p),
                      PreConfig(
                        textStyle: theme.textTheme.small.copyWith(
                          fontFamily: 'JetBrainsMono',
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.muted,
                          borderRadius: theme.radii.md,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
