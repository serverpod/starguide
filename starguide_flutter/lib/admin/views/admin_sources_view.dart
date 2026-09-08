import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shad/shad.dart';
import 'package:starguide_client/starguide_client.dart';
import 'package:starguide_flutter/admin/admin_format.dart';
import 'package:starguide_flutter/admin/widgets/admin_widgets.dart';
import 'package:starguide_flutter/main.dart';
import 'package:url_launcher/url_launcher.dart';

/// Lists every document used to answer questions, with filters and a
/// detail view of each document.
class AdminSourcesView extends StatefulWidget {
  const AdminSourcesView({super.key});

  @override
  State<AdminSourcesView> createState() => _AdminSourcesViewState();
}

class _AdminSourcesViewState extends State<AdminSourcesView> {
  static const _pageSize = 25;
  static const _allFilter = 'all';

  late Future<AdminDocumentPage> _future;
  late Future<List<String>> _domainsFuture;

  int _page = 0;
  RAGDocumentType? _type;
  String? _domain;
  String _search = '';
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _domainsFuture = client.admin.listDocumentDomains();
    _load();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _load() {
    setState(() {
      _future = client.admin.listDocuments(
        page: _page,
        pageSize: _pageSize,
        type: _type,
        domain: _domain,
        search: _search.isEmpty ? null : _search,
      );
    });
  }

  void _reload() {
    _domainsFuture = client.admin.listDocumentDomains();
    _load();
  }

  void _setFilter(void Function() update) {
    update();
    _page = 0;
    _load();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted || value == _search) return;
      _setFilter(() => _search = value.trim());
    });
  }

  void _showDocument(AdminDocumentSummary summary) {
    showShadSheet<void>(
      context: context,
      side: ShadSheetSide.right,
      builder: (context) => _DocumentSheet(summary: summary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        AdminViewHeader(
          title: 'Sources',
          description:
              'The documents that answers are based on. Click a document '
              'to inspect it.',
          trailing: ShadButton.outline(
            onPressed: _reload,
            leading: const Icon(LucideIcons.refreshCw),
            child: const Text('Refresh'),
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 280,
              child: ShadInput(
                placeholder: const Text('Search titles'),
                leading: const Icon(LucideIcons.search),
                onChanged: _onSearchChanged,
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 180),
              child: ShadSelect<String>(
                initialValue: _allFilter,
                options: [
                  const ShadOption(value: _allFilter, child: Text('All types')),
                  for (final type in RAGDocumentType.values)
                    ShadOption(
                      value: type.name,
                      child: Text(documentTypeLabel(type)),
                    ),
                ],
                selectedOptionBuilder: (context, value) => Text(
                  value == _allFilter
                      ? 'All types'
                      : documentTypeLabel(RAGDocumentType.values.byName(value)),
                ),
                onChanged: (value) => _setFilter(() {
                  _type = value == null || value == _allFilter
                      ? null
                      : RAGDocumentType.values.byName(value);
                }),
              ),
            ),
            FutureBuilder<List<String>>(
              future: _domainsFuture,
              builder: (context, snapshot) {
                final domains = snapshot.data ?? const <String>[];
                return ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 200),
                  child: ShadSelect<String>(
                    initialValue: _domain ?? _allFilter,
                    options: [
                      const ShadOption(
                        value: _allFilter,
                        child: Text('All domains'),
                      ),
                      for (final domain in domains)
                        ShadOption(value: domain, child: Text(domain)),
                    ],
                    selectedOptionBuilder: (context, value) =>
                        Text(value == _allFilter ? 'All domains' : value),
                    onChanged: (value) => _setFilter(() {
                      _domain = value == null || value == _allFilter
                          ? null
                          : value;
                    }),
                  ),
                );
              },
            ),
          ],
        ),
        AdminAsyncContent<AdminDocumentPage>(
          future: _future,
          onRetry: _load,
          builder: (context, page) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              _DocumentsTable(documents: page.documents, onTap: _showDocument),
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

class _DocumentsTable extends StatelessWidget {
  const _DocumentsTable({required this.documents, required this.onTap});

  final List<AdminDocumentSummary> documents;
  final ValueChanged<AdminDocumentSummary> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return AdminTableCard(
      emptyMessage: 'No documents match the filters.',
      onRowTap: (row) => onTap(documents[row]),
      columnWidths: const [null, 140, 170, 150, 100],
      minFlexibleWidth: 280,
      header: const [
        ShadTableCell.header(child: Text('Title')),
        ShadTableCell.header(child: Text('Type')),
        ShadTableCell.header(child: Text('Domain')),
        ShadTableCell.header(child: Text('Fetched')),
        ShadTableCell.header(
          alignment: Alignment.centerRight,
          child: Text('Size'),
        ),
      ],
      rows: [
        for (final document in documents)
          [
            ShadTableCell(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.title,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.small,
                  ),
                  Text(
                    document.sourceUrl.toString(),
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.muted.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            ShadTableCell(child: DocumentTypeBadge(type: document.type)),
            ShadTableCell(
              child: Text(document.domain, overflow: TextOverflow.ellipsis),
            ),
            ShadTableCell(
              child: ShadTooltip(
                builder: (context) => Text(
                  formatDateTime(document.fetchTime),
                  style: theme.textTheme.small,
                ),
                child: Text(formatRelative(document.fetchTime)),
              ),
            ),
            ShadTableCell(
              alignment: Alignment.centerRight,
              child: Text(formatCompactCount(document.contentLength)),
            ),
          ],
      ],
    );
  }
}

/// A side sheet with the full document.
class _DocumentSheet extends StatefulWidget {
  const _DocumentSheet({required this.summary});

  final AdminDocumentSummary summary;

  @override
  State<_DocumentSheet> createState() => _DocumentSheetState();
}

class _DocumentSheetState extends State<_DocumentSheet> {
  late Future<AdminDocumentDetail> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = client.admin.getDocument(widget.summary.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final summary = widget.summary;

    return ShadSheet(
      constraints: const BoxConstraints(maxWidth: 760),
      title: Text(summary.title),
      description: Text(summary.sourceUrl.toString()),
      actions: [
        ShadButton.outline(
          onPressed: () => launchUrl(summary.sourceUrl),
          leading: const Icon(LucideIcons.externalLink),
          child: const Text('Open source'),
        ),
      ],
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
                DocumentTypeBadge(type: summary.type),
                ShadBadge.outline(child: Text(summary.domain)),
              ],
            ),
            AdminDetailRow(
              label: 'Fetched',
              value: Text(
                '${formatDateTime(summary.fetchTime)} '
                '(${formatRelative(summary.fetchTime)})',
              ),
            ),
            AdminDetailRow(label: 'Document id', value: Text('${summary.id}')),
            AdminAsyncContent<AdminDocumentDetail>(
              future: _future,
              onRetry: _load,
              builder: (context, detail) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                spacing: 16,
                children: [
                  _Section(
                    title: 'Short description',
                    description:
                        'Shown to the model when it picks documents to '
                        'answer from.',
                    child: SelectableText(
                      detail.shortDescription,
                      style: theme.textTheme.p,
                    ),
                  ),
                  _Section(
                    title: 'Embedding summary',
                    description:
                        'The text the embedding vector was generated from.',
                    child: SelectableText(
                      detail.embeddingSummary,
                      style: theme.textTheme.p,
                    ),
                  ),
                  _Section(
                    title: 'Content',
                    description:
                        '${formatCount(detail.content.length)} characters '
                        'passed to the model when the document is used.',
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.muted,
                        borderRadius: theme.radii.md,
                      ),
                      child: SelectableText(
                        detail.content,
                        style: theme.textTheme.small.copyWith(
                          fontFamily: 'JetBrainsMono',
                          height: 1.5,
                        ),
                      ),
                    ),
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

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Text(title, style: theme.textTheme.large),
        Text(description, style: theme.textTheme.muted),
        child,
      ],
    );
  }
}
