import 'package:flutter/material.dart';
import 'package:shad/shad.dart';
import 'package:starguide_client/starguide_client.dart';
import 'package:starguide_flutter/admin/widgets/admin_widgets.dart';
import 'package:starguide_flutter/admin/widgets/chat_session_widgets.dart';
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
              ChatSessionsTable(
                sessions: page.sessions,
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
