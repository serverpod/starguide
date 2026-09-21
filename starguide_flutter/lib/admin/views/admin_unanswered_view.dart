import 'package:flutter/material.dart';
import 'package:shad/shad.dart';
import 'package:starguide_client/starguide_client.dart';
import 'package:starguide_flutter/admin/widgets/admin_widgets.dart';
import 'package:starguide_flutter/admin/widgets/chat_session_widgets.dart';
import 'package:starguide_flutter/main.dart';

/// Which judged chat sessions to list.
enum _OutcomeFilter {
  notAnswered('Not answered', [AnswerOutcome.notAnswered]),
  notAnsweredOrUnsure('Not answered or unsure', [
    AnswerOutcome.notAnswered,
    AnswerOutcome.unsure,
  ]),
  unsure('Unsure', [AnswerOutcome.unsure]),
  answered('Answered', [AnswerOutcome.answered]),
  judged('All judged', AnswerOutcome.values);

  const _OutcomeFilter(this.label, this.outcomes);

  final String label;
  final List<AnswerOutcome> outcomes;
}

/// Lists conversations whose latest answer Jev judged not to have answered
/// the question, so the gaps in the documentation can be found.
class AdminUnansweredView extends StatefulWidget {
  const AdminUnansweredView({super.key});

  @override
  State<AdminUnansweredView> createState() => _AdminUnansweredViewState();
}

class _AdminUnansweredViewState extends State<AdminUnansweredView> {
  static const _pageSize = 25;

  late Future<AdminChatSessionPage> _future;
  int _page = 0;
  _OutcomeFilter _filter = _OutcomeFilter.notAnswered;

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
        goodAnswer: null,
        votedOnly: false,
        outcomes: _filter.outcomes,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        AdminViewHeader(
          title: 'Unanswered',
          description:
              'Conversations where Jev judged that the latest answer did not '
              'resolve the question. Click a conversation to read it.',
          trailing: ShadButton.outline(
            onPressed: _load,
            leading: const Icon(LucideIcons.refreshCw),
            child: const Text('Refresh'),
          ),
        ),
        Row(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 220),
              child: ShadSelect<_OutcomeFilter>(
                initialValue: _filter,
                options: [
                  for (final filter in _OutcomeFilter.values)
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
              ChatSessionsTable(
                sessions: page.sessions,
                emptyMessage: 'No judged conversations match the filter.',
                onTap: (summary) => showConversationSheet(context, summary),
              ),
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
