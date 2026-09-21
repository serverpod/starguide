import 'package:flutter/material.dart';
import 'package:shad/shad.dart';
import 'package:starguide_client/starguide_client.dart';
import 'package:starguide_flutter/admin/admin_format.dart';
import 'package:starguide_flutter/admin/widgets/admin_widgets.dart';
import 'package:starguide_flutter/main.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows the document index as it is cached for Jev: the groups of pages
/// that become choice questions, their sizes, and the payloads sent.
class AdminDocumentIndexView extends StatefulWidget {
  const AdminDocumentIndexView({super.key});

  @override
  State<AdminDocumentIndexView> createState() => _AdminDocumentIndexViewState();
}

class _AdminDocumentIndexViewState extends State<AdminDocumentIndexView> {
  late Future<AdminDocumentIndex> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = client.admin.getDocumentIndex();
    });
  }

  void _rebuild() {
    setState(() {
      _future = client.admin.rebuildDocumentIndex();
    });
  }

  void _showGroup(AdminDocumentIndex index, int groupIndex) {
    showShadSheet<void>(
      context: context,
      side: ShadSheetSide.right,
      builder: (context) => _GroupSheet(
        group: index.index.groups[groupIndex],
        payload: index.groupPayloads[groupIndex],
      ),
    );
  }

  void _showDomainPayload(AdminDocumentIndex index) {
    showShadSheet<void>(
      context: context,
      side: ShadSheetSide.right,
      builder: (context) => ShadSheet(
        constraints: const BoxConstraints(maxWidth: 760),
        title: const Text('Domain question'),
        description: const Text(
          'The options of the question asking which product a question is '
          'about, as sent to Jev.',
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: _PayloadView(payload: index.domainPayload),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        AdminViewHeader(
          title: 'Document Index',
          description:
              'The pages Jev picks from when answering a question, grouped '
              'into one question per source. Click a group to see its pages '
              'and the payload sent to Jev.',
          trailing: Row(
            spacing: 8,
            children: [
              ShadButton.outline(
                onPressed: _rebuild,
                leading: const Icon(LucideIcons.hammer),
                child: const Text('Rebuild'),
              ),
              ShadButton.outline(
                onPressed: _load,
                leading: const Icon(LucideIcons.refreshCw),
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
        AdminAsyncContent<AdminDocumentIndex>(
          future: _future,
          onRetry: _load,
          builder: (context, index) => _IndexContent(
            index: index,
            onGroupTap: (groupIndex) => _showGroup(index, groupIndex),
            onDomainPayloadTap: () => _showDomainPayload(index),
          ),
        ),
      ],
    );
  }
}

class _IndexContent extends StatelessWidget {
  const _IndexContent({
    required this.index,
    required this.onGroupTap,
    required this.onDomainPayloadTap,
  });

  final AdminDocumentIndex index;
  final ValueChanged<int> onGroupTap;
  final VoidCallback onDomainPayloadTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final groups = index.index.groups;
    final splitDomains = {
      for (final group in groups)
        if (group.name != group.domain) group.domain,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            AdminStatCard(
              title: 'Pages',
              icon: LucideIcons.fileText,
              value: formatCount(index.entryCount),
              description:
                  'In ${groups.length} '
                  '${groups.length == 1 ? 'question' : 'questions'}',
            ),
            AdminStatCard(
              title: 'Size',
              icon: LucideIcons.database,
              value: formatBytes(index.totalSizeInBytes),
              description:
                  'About ${formatCount(index.estimatedTokens)} tokens per '
                  'question asked',
            ),
            AdminStatCard(
              title: 'Built',
              icon: LucideIcons.clock,
              value: formatRelative(index.index.generatedAt),
              description: index.expiresAt.isBefore(DateTime.now())
                  ? 'Rebuilt on the next question'
                  : 'Cached until ${formatDateTime(index.expiresAt)}',
            ),
          ],
        ),
        ShadCard(
          title: const Text('Questions'),
          description: const Text(
            'Each group of pages is one choice question, where every page '
            'is an option. A domain question weighs the groups against each '
            'other.',
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                if (splitDomains.isNotEmpty)
                  ShadAlert(
                    icon: const Icon(LucideIcons.info),
                    title: const Text('Split sources'),
                    description: Text(
                      '${splitDomains.join(', ')} '
                      '${splitDomains.length == 1 ? 'has' : 'have'} more '
                      'pages than fit in one question and '
                      '${splitDomains.length == 1 ? 'is' : 'are'} asked '
                      'about in several.',
                    ),
                  ),
                AdminTableCard(
                  emptyMessage: 'No pages are indexed.',
                  onRowTap: onGroupTap,
                  columnWidths: const [null, 140, 100, 110],
                  minFlexibleWidth: 240,
                  header: const [
                    ShadTableCell.header(child: Text('Group')),
                    ShadTableCell.header(child: Text('Type')),
                    ShadTableCell.header(
                      alignment: Alignment.centerRight,
                      child: Text('Pages'),
                    ),
                    ShadTableCell.header(
                      alignment: Alignment.centerRight,
                      child: Text('Size'),
                    ),
                  ],
                  rows: [
                    for (final group in groups)
                      [
                        ShadTableCell(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                group.name,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.small,
                              ),
                              if (group.description.isNotEmpty)
                                Text(
                                  group.description,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.muted.copyWith(
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        ShadTableCell(
                          child: DocumentTypeBadge(type: group.type),
                        ),
                        ShadTableCell(
                          alignment: Alignment.centerRight,
                          child: Text(formatCount(group.entries.length)),
                        ),
                        ShadTableCell(
                          alignment: Alignment.centerRight,
                          child: Text(formatBytes(group.sizeInBytes)),
                        ),
                      ],
                  ],
                ),
                Row(
                  children: [
                    ShadButton.ghost(
                      onPressed: onDomainPayloadTap,
                      leading: const Icon(LucideIcons.braces),
                      child: Text(
                        'Domain question '
                        '(${formatBytes(index.domainPayload.length)})',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Text(
          'The index is built from the documentation and website pages in '
          'the database and cached for an hour, or until a page is fetched '
          'again.',
          style: theme.textTheme.muted,
        ),
      ],
    );
  }
}

/// A side sheet with the pages of a group and the payload sent to Jev.
class _GroupSheet extends StatefulWidget {
  const _GroupSheet({required this.group, required this.payload});

  final DocumentIndexGroup group;
  final String payload;

  @override
  State<_GroupSheet> createState() => _GroupSheetState();
}

class _GroupSheetState extends State<_GroupSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final group = widget.group;
    final query = _search.trim().toLowerCase();
    final entries = [
      for (final entry in group.entries)
        if (query.isEmpty ||
            entry.label.toLowerCase().contains(query) ||
            entry.title.toLowerCase().contains(query) ||
            entry.description.toLowerCase().contains(query))
          entry,
    ];

    return ShadSheet(
      constraints: const BoxConstraints(maxWidth: 760),
      title: Text(group.name),
      description: Text(
        '${formatCount(group.entries.length)} pages · '
        '${formatBytes(group.sizeInBytes)}',
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ShadTabs<String>(
          value: 'pages',
          tabs: [
            ShadTab(
              value: 'pages',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  ShadInput(
                    placeholder: const Text('Search pages'),
                    leading: const Icon(LucideIcons.search),
                    onChanged: (value) => setState(() => _search = value),
                  ),
                  if (entries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No pages match the search.',
                          style: theme.textTheme.muted,
                        ),
                      ),
                    ),
                  for (final entry in entries) _EntryTile(entry: entry),
                ],
              ),
              child: const Text('Pages'),
            ),
            ShadTab(
              value: 'payload',
              content: _PayloadView(payload: widget.payload),
              child: const Text('Payload'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final DocumentIndexEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border),
        borderRadius: theme.radii.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  entry.label,
                  style: theme.textTheme.small.copyWith(
                    fontFamily: 'JetBrainsMono',
                  ),
                ),
              ),
              Text(
                formatBytes(entry.sizeInBytes),
                style: theme.textTheme.muted,
              ),
            ],
          ),
          Text(entry.title, style: theme.textTheme.small),
          Text(entry.description, style: theme.textTheme.muted),
          Row(
            children: [
              ShadTooltip(
                builder: (context) => Text(
                  entry.sourceUrl.toString(),
                  style: theme.textTheme.small,
                ),
                child: ShadButton.link(
                  padding: EdgeInsets.zero,
                  height: 20,
                  leading: const Icon(LucideIcons.externalLink, size: 14),
                  onPressed: () => launchUrl(entry.sourceUrl),
                  child: const Text('Link'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A JSON payload, formatted for reading.
class _PayloadView extends StatelessWidget {
  const _PayloadView({required this.payload});

  final String payload;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted,
        borderRadius: theme.radii.md,
      ),
      child: SelectableText(
        _pretty(payload),
        style: theme.textTheme.small.copyWith(fontFamily: 'JetBrainsMono'),
      ),
    );
  }

  /// The JSON object with one option per line, as it is sent compact.
  static String _pretty(String json) {
    final buffer = StringBuffer();
    var inString = false;
    var escaped = false;
    for (final char in json.runes) {
      final c = String.fromCharCode(char);
      if (escaped) {
        buffer.write(c);
        escaped = false;
        continue;
      }
      if (c == r'\' && inString) {
        buffer.write(c);
        escaped = true;
        continue;
      }
      if (c == '"') inString = !inString;
      if (!inString && c == ',') {
        buffer.write(',\n');
        continue;
      }
      if (!inString && c == '{') {
        buffer.write('{\n');
        continue;
      }
      if (!inString && c == '}') {
        buffer.write('\n}');
        continue;
      }
      buffer.write(c);
    }
    return buffer.toString();
  }
}
