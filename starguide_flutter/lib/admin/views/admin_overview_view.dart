import 'package:flutter/material.dart';
import 'package:shad/shad.dart';
import 'package:starguide_client/starguide_client.dart';
import 'package:starguide_flutter/admin/admin_format.dart';
import 'package:starguide_flutter/admin/widgets/admin_widgets.dart';
import 'package:starguide_flutter/admin/widgets/vote_history_chart.dart';
import 'package:starguide_flutter/main.dart';

/// Overview of the loaded data and how the answers are voted.
class AdminOverviewView extends StatefulWidget {
  const AdminOverviewView({super.key});

  @override
  State<AdminOverviewView> createState() => _AdminOverviewViewState();
}

class _AdminOverviewViewState extends State<AdminOverviewView> {
  late Future<AdminOverview> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _future = client.admin.getOverview();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        AdminViewHeader(
          title: 'Overview',
          description: 'Loaded sources and how the answers are rated.',
          trailing: ShadButton.outline(
            onPressed: _load,
            leading: const Icon(LucideIcons.refreshCw),
            child: const Text('Refresh'),
          ),
        ),
        AdminAsyncContent<AdminOverview>(
          future: _future,
          onRetry: _load,
          builder: (context, overview) => _OverviewContent(overview: overview),
        ),
      ],
    );
  }
}

class _OverviewContent extends StatelessWidget {
  const _OverviewContent({required this.overview});

  final AdminOverview overview;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final week = overview.lastWeek;
    final month = overview.lastMonth;
    final nextFetchTimes = overview.sources
        .map((source) => source.nextFetchTime)
        .nonNulls
        .toList();
    final nextFetchTime = nextFetchTimes.isEmpty
        ? null
        : nextFetchTimes.reduce((a, b) => a.isBefore(b) ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            AdminStatCard(
              title: 'Documents',
              icon: LucideIcons.fileText,
              value: formatCount(overview.documentCount),
              description:
                  'From ${overview.sources.length} data '
                  '${overview.sources.length == 1 ? 'source' : 'sources'}',
            ),
            AdminStatCard(
              title: 'Sessions, 7 days',
              icon: LucideIcons.messagesSquare,
              value: formatCount(week.sessionCount),
              description:
                  '${formatCount(month.sessionCount)} in 30 days · '
                  '${formatCount(overview.totalSessionCount)} total',
            ),
            AdminStatCard(
              title: 'Got Help, 7 days',
              icon: LucideIcons.thumbsUp,
              value: formatGotHelpRatio(week),
              description: _voteDescription(week),
            ),
            AdminStatCard(
              title: 'Got Help, 30 days',
              icon: LucideIcons.thumbsUp,
              value: formatGotHelpRatio(month),
              description: _voteDescription(month),
            ),
            AdminStatCard(
              title: 'Last fetch',
              icon: LucideIcons.download,
              value: overview.lastFetchTime == null
                  ? 'Never'
                  : formatRelative(overview.lastFetchTime!),
              description: nextFetchTime == null
                  ? 'No fetch scheduled'
                  : 'Next fetch ${formatRelative(nextFetchTime)}',
            ),
          ],
        ),
        ShadCard(
          title: const Text('Votes per day'),
          description: const Text(
            'Chat sessions created during the past 30 days, by how the '
            'answer was rated.',
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: VoteHistoryChart(stats: overview.dailyStats),
          ),
        ),
        ShadCard(
          title: const Text('Data sources'),
          description: const Text(
            'Documents loaded from each source and when they are refreshed.',
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _SourcesTable(sources: overview.sources),
          ),
        ),
        ShadCard(
          title: const Text('Fetching'),
          description: const Text('How the documents are kept up to date.'),
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                AdminDetailRow(
                  label: 'Fetch interval',
                  value: Text(
                    'Every ${formatDuration(overview.fetchInterval)}',
                  ),
                ),
                AdminDetailRow(
                  label: 'Remove stale documents',
                  value: Text(
                    'After ${formatDuration(overview.removeOldDataAfter)} '
                    'without a successful fetch',
                  ),
                ),
                AdminDetailRow(
                  label: 'Next clean up',
                  value: Text(_timeWithRelative(overview.nextCleanUpTime)),
                ),
                AdminDetailRow(
                  label: 'Oldest document',
                  value: Text(_timeWithRelative(overview.oldestFetchTime)),
                ),
                AdminDetailRow(
                  label: 'Stored messages',
                  value: Text(formatCount(overview.totalMessageCount)),
                ),
                AdminDetailRow(
                  label: 'Statistics computed',
                  value: Text(formatDateTime(overview.computedAt)),
                ),
              ],
            ),
          ),
        ),
        Text(
          'Daily statistics for past days are cached in the database. The '
          'most recent days are recomputed on every refresh.',
          style: theme.textTheme.muted,
        ),
      ],
    );
  }

  static String _voteDescription(VoteStats stats) {
    final noVote =
        stats.sessionCount - stats.goodAnswerCount - stats.poorAnswerCount;
    return '${formatCount(stats.goodAnswerCount)} got help · '
        '${formatCount(stats.poorAnswerCount)} poor · '
        '${formatCount(noVote)} no vote';
  }

  static String _timeWithRelative(DateTime? time) {
    if (time == null) return '–';
    return '${formatDateTime(time)} (${formatRelative(time)})';
  }
}

class _SourcesTable extends StatelessWidget {
  const _SourcesTable({required this.sources});

  final List<AdminSourceStatus> sources;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return AdminTableCard(
      emptyMessage: 'No data sources are configured.',
      columnSpanExtent: (column) => switch (column) {
        0 => const MaxTableSpanExtent(
          FixedTableSpanExtent(240),
          RemainingTableSpanExtent(),
        ),
        1 => const FixedTableSpanExtent(170),
        2 => const FixedTableSpanExtent(140),
        3 => const FixedTableSpanExtent(110),
        4 => const FixedTableSpanExtent(150),
        _ => const FixedTableSpanExtent(220),
      },
      header: const [
        ShadTableCell.header(child: Text('Source')),
        ShadTableCell.header(child: Text('Domain')),
        ShadTableCell.header(child: Text('Type')),
        ShadTableCell.header(
          alignment: Alignment.centerRight,
          child: Text('Documents'),
        ),
        ShadTableCell.header(child: Text('Last fetched')),
        ShadTableCell.header(child: Text('Next fetch')),
      ],
      rows: [
        for (final source in sources)
          [
            ShadTableCell(
              child: Text(source.name, overflow: TextOverflow.ellipsis),
            ),
            ShadTableCell(
              child: Text(source.domain, overflow: TextOverflow.ellipsis),
            ),
            ShadTableCell(child: DocumentTypeBadge(type: source.type)),
            ShadTableCell(
              alignment: Alignment.centerRight,
              child: Text(formatCount(source.documentCount)),
            ),
            ShadTableCell(
              child: Text(
                source.lastFetchTime == null
                    ? 'Never'
                    : formatRelative(source.lastFetchTime!),
              ),
            ),
            ShadTableCell(
              child: Row(
                spacing: 8,
                children: [
                  Flexible(
                    child: Text(
                      source.nextFetchTime == null
                          ? 'Not scheduled'
                          : formatRelative(source.nextFetchTime!),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (source.retryTime != null)
                    ShadTooltip(
                      builder: (context) => Text(
                        'The last fetch failed. A retry is scheduled '
                        '${formatRelative(source.retryTime!)}.',
                        style: theme.textTheme.small,
                      ),
                      child: const ShadBadge.destructive(child: Text('Retry')),
                    ),
                ],
              ),
            ),
          ],
      ],
    );
  }
}
