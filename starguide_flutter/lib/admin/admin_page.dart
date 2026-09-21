import 'package:flutter/material.dart';
import 'package:shad/shad.dart';
import 'package:starguide_flutter/admin/views/admin_document_index_view.dart';
import 'package:starguide_flutter/admin/views/admin_overview_view.dart';
import 'package:starguide_flutter/admin/views/admin_poor_answers_view.dart';
import 'package:starguide_flutter/admin/views/admin_sources_view.dart';
import 'package:starguide_flutter/admin/views/admin_unanswered_view.dart';

enum _AdminSection {
  overview('Overview', LucideIcons.chartColumn),
  sources('Sources', LucideIcons.database),
  documentIndex('Document Index', LucideIcons.listTree),
  poorAnswers('Poor Answers', LucideIcons.thumbsDown),
  unanswered('Unanswered', LucideIcons.messageCircleQuestionMark);

  const _AdminSection(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// The admin interface. Replaces the chat while open; [onClose] returns to
/// the chat.
class AdminPage extends StatefulWidget {
  const AdminPage({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  _AdminSection _section = _AdminSection.overview;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: ShadSidebarScaffold(
        sidebar: ShadSidebar(
          collapsible: ShadSidebarCollapsible.icon,
          rail: true,
          header: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: theme.radii.md,
                ),
                child: Icon(
                  LucideIcons.telescope,
                  size: 16,
                  color: theme.colorScheme.primaryForeground,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Admin',
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.clip,
                  style: theme.textTheme.small,
                ),
              ),
            ],
          ),
          footer: ShadSidebarMenuButton(
            leading: const Icon(LucideIcons.arrowLeft),
            tooltip: 'Back to chat',
            onPressed: widget.onClose,
            child: const Text('Back to chat'),
          ),
          children: [
            ShadSidebarGroup(
              label: const Text('Insights'),
              children: [
                ShadSidebarMenu(
                  children: [
                    _menuButton(_AdminSection.overview),
                    _menuButton(_AdminSection.poorAnswers),
                    _menuButton(_AdminSection.unanswered),
                  ],
                ),
              ],
            ),
            ShadSidebarGroup(
              label: const Text('Data'),
              children: [
                ShadSidebarMenu(
                  children: [
                    _menuButton(_AdminSection.sources),
                    _menuButton(_AdminSection.documentIndex),
                  ],
                ),
              ],
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const ShadSidebarTrigger(),
                  const SizedBox(
                    height: 16,
                    child: ShadSeparator.vertical(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                  Text(_section.label, style: theme.textTheme.small),
                ],
              ),
            ),
            const ShadSeparator.horizontal(margin: EdgeInsets.zero),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: switch (_section) {
                    _AdminSection.overview => const AdminOverviewView(),
                    _AdminSection.sources => const AdminSourcesView(),
                    _AdminSection.documentIndex =>
                      const AdminDocumentIndexView(),
                    _AdminSection.unanswered => const AdminUnansweredView(),
                    _AdminSection.poorAnswers => const AdminPoorAnswersView(),
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ShadSidebarMenuButton _menuButton(_AdminSection section) {
    return ShadSidebarMenuButton(
      leading: Icon(section.icon),
      isActive: _section == section,
      tooltip: section.label,
      onPressed: () => setState(() => _section = section),
      child: Text(section.label),
    );
  }
}
