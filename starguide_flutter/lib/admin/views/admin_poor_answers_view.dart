import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:shad/shad.dart';
import 'package:starguide_client/starguide_client.dart';
import 'package:starguide_flutter/admin/admin_format.dart';
import 'package:starguide_flutter/admin/widgets/admin_widgets.dart';
import 'package:starguide_flutter/main.dart';

/// Which chat sessions to list.
enum _SessionFilter {
  poor('Poor Answer'),
  good('Got Help'),
  voted('Any vote'),
  all('All sessions');

  const _SessionFilter(this.label);

  final String label;
}

/// Lists conversations where the answer was voted poor, so they can be
/// reviewed. Other sessions can be listed with the filter.
class AdminPoorAnswersView extends StatefulWidget {
  const AdminPoorAnswersView({super.key});

  @override
  State<AdminPoorAnswersView> createState() => _AdminPoorAnswersViewState();
}

class _AdminPoorAnswersViewState extends State<AdminPoorAnswersView> {
  static const _pageSize = 25;

  late Future<AdminChatSessionPage> _future;
  int _page = 0;
  _SessionFilter _filter = _SessionFilter.poor;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = client.admin.listChatSessions(
        page: _page,
        pageSize: _pageSize,
        goodAnswer: switch (_filter) {
          _SessionFilter.poor => false,
          _SessionFilter.good => true,
          _SessionFilter.voted || _SessionFilter.all => null,
        },
        votedOnly: _filter == _SessionFilter.voted,
      );
    });
  }

  void _showSession(AdminChatSessionSummary summary) {
    showShadSheet<void>(
      context: context,
      side: ShadSheetSide.right,
      builder: (context) => _ConversationSheet(summary: summary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        AdminViewHeader(
          title: 'Poor Answers',
          description:
              'Conversations where the answer was rated poor. Click a '
              'conversation to read it.',
          trailing: ShadButton.outline(
            onPressed: _load,
            leading: const Icon(LucideIcons.refreshCw),
            child: const Text('Refresh'),
          ),
        ),
        Row(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 180),
              child: ShadSelect<_SessionFilter>(
                initialValue: _filter,
                options: [
                  for (final filter in _SessionFilter.values)
                    ShadOption(value: filter, child: Text(filter.label)),
                ],
                selectedOptionBuilder: (context, value) => Text(value.label),
                onChanged: (value) {
                  if (value == null) return;
                  _filter = value;
                  _page = 0;
                  _load();
                },
              ),
            ),
          ],
        ),
        AdminAsyncContent<AdminChatSessionPage>(
          future: _future,
          onRetry: _load,
          builder: (context, page) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              _SessionsTable(sessions: page.sessions, onTap: _showSession),
              AdminPagination(
                page: page.page,
                pageSize: page.pageSize,
                totalCount: page.totalCount,
                onPageChanged: (value) {
                  _page = value;
                  _load();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SessionsTable extends StatelessWidget {
  const _SessionsTable({required this.sessions, required this.onTap});

  final List<AdminChatSessionSummary> sessions;
  final ValueChanged<AdminChatSessionSummary> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return AdminTableCard(
      emptyMessage: 'No conversations match the filter.',
      onRowTap: (row) => onTap(sessions[row]),
      columnSpanExtent: (column) => switch (column) {
        0 => const FixedTableSpanExtent(150),
        1 => const MaxTableSpanExtent(
          FixedTableSpanExtent(320),
          RemainingTableSpanExtent(),
        ),
        2 => const FixedTableSpanExtent(100),
        3 => const FixedTableSpanExtent(130),
        _ => const FixedTableSpanExtent(110),
      },
      header: const [
        ShadTableCell.header(child: Text('Started')),
        ShadTableCell.header(child: Text('First question')),
        ShadTableCell.header(
          alignment: Alignment.centerRight,
          child: Text('Messages'),
        ),
        ShadTableCell.header(child: Text('Vote')),
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
class _ConversationSheet extends StatefulWidget {
  const _ConversationSheet({required this.summary});

  final AdminChatSessionSummary summary;

  @override
  State<_ConversationSheet> createState() => _ConversationSheetState();
}

class _ConversationSheetState extends State<_ConversationSheet> {
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
