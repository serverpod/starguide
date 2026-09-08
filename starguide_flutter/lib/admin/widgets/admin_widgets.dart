import 'dart:math' as math;

import 'package:flutter/material.dart' hide Table;
import 'package:shad/shad.dart';
import 'package:starguide_client/starguide_client.dart';
import 'package:starguide_flutter/admin/admin_format.dart';

/// Shows a spinner while [future] is pending, an error with a retry button
/// if it fails, and [builder]'s widget once it completes.
class AdminAsyncContent<T> extends StatelessWidget {
  const AdminAsyncContent({
    super.key,
    required this.future,
    required this.builder,
    required this.onRetry,
  });

  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AdminError(error: snapshot.error!, onRetry: onRetry);
        }
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(48),
            child: Center(child: ShadSpinner()),
          );
        }
        return builder(context, snapshot.data as T);
      },
    );
  }
}

/// An error message with a retry button.
class AdminError extends StatelessWidget {
  const AdminError({super.key, required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          ShadAlert.destructive(
            icon: const Icon(LucideIcons.circleAlert),
            title: const Text('Failed to load data'),
            description: Text('$error'),
          ),
          ShadButton.outline(
            onPressed: onRetry,
            leading: const Icon(LucideIcons.refreshCw),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

/// The heading of a view, with an optional trailing widget such as a
/// refresh button.
class AdminViewHeader extends StatelessWidget {
  const AdminViewHeader({
    super.key,
    required this.title,
    this.description,
    this.trailing,
  });

  final String title;
  final String? description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(title, style: theme.textTheme.h3),
              if (description != null)
                Text(description!, style: theme.textTheme.muted),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// A card showing a single headline number.
class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    this.description,
    this.icon,
  });

  final String title;
  final String value;
  final String? description;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      width: 232,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.small,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (icon != null)
                Icon(icon, size: 16, color: theme.colorScheme.mutedForeground),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.h2),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: theme.textTheme.muted,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// A badge showing the vote of a chat session.
class VoteBadge extends StatelessWidget {
  const VoteBadge({super.key, required this.goodAnswer});

  final bool? goodAnswer;

  @override
  Widget build(BuildContext context) {
    return switch (goodAnswer) {
      true => const ShadBadge.secondary(child: Text('Got Help')),
      false => const ShadBadge.destructive(child: Text('Poor Answer')),
      null => const ShadBadge.outline(child: Text('No vote')),
    };
  }
}

/// A badge showing the type of a document.
class DocumentTypeBadge extends StatelessWidget {
  const DocumentTypeBadge({super.key, required this.type});

  final RAGDocumentType type;

  @override
  Widget build(BuildContext context) {
    final label = Text(documentTypeLabel(type));
    return switch (type) {
      RAGDocumentType.documentation => ShadBadge.secondary(child: label),
      RAGDocumentType.discussion => ShadBadge.outline(child: label),
      RAGDocumentType.issue => ShadBadge.outline(child: label),
    };
  }
}

/// A table in a card, sized to fit its header and rows exactly.
///
/// [columnWidths] gives the width of each column. Exactly one entry may be
/// null: that column takes the width left over by the others, but never
/// less than [minFlexibleWidth], so the table only scrolls horizontally
/// when the card is too narrow for all columns. Rows are indexed without the
/// header in [onRowTap].
class AdminTableCard extends StatelessWidget {
  const AdminTableCard({
    super.key,
    required this.header,
    required this.rows,
    required this.columnWidths,
    this.minFlexibleWidth = 200,
    this.onRowTap,
    this.emptyMessage = 'Nothing to show.',
  }) : assert(
         header.length == columnWidths.length,
         'One width per header cell is required.',
       );

  final List<ShadTableCell> header;
  final List<List<ShadTableCell>> rows;
  final List<double?> columnWidths;
  final double minFlexibleWidth;
  final void Function(int row)? onRowTap;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final rowHeight = theme.tableTheme.cellHeight ?? 48;

    // ShadTable.list requires at least one row, so an empty result shows
    // a message instead of the table.
    if (rows.isEmpty) {
      return ShadCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(emptyMessage, style: theme.textTheme.muted),
          ),
        ),
      );
    }

    return ShadCard(
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: rowHeight * (rows.length + 1),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fixedTotal = columnWidths.nonNulls.fold(0.0, (a, b) => a + b);
            final flexibleWidth = math.max(
              minFlexibleWidth,
              constraints.maxWidth - fixedTotal,
            );
            return ShadTable.list(
              columnSpanExtent: (column) =>
                  FixedTableSpanExtent(columnWidths[column] ?? flexibleWidth),
              header: header,
              onRowTap: onRowTap == null
                  ? null
                  : (row) {
                      // Row 0 is the header.
                      if (row > 0) onRowTap!(row - 1);
                    },
              children: rows,
            );
          },
        ),
      ),
    );
  }
}

/// A footer for paged tables: the range shown and page controls.
class AdminPagination extends StatelessWidget {
  const AdminPagination({
    super.key,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.onPageChanged,
  });

  final int page;
  final int pageSize;
  final int totalCount;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final pageCount = (totalCount / pageSize).ceil().clamp(1, 1 << 30);
    final first = totalCount == 0 ? 0 : page * pageSize + 1;
    final last = ((page + 1) * pageSize).clamp(0, totalCount);

    return Row(
      children: [
        Expanded(
          child: Text(
            'Showing ${formatCount(first)}–${formatCount(last)} of '
            '${formatCount(totalCount)}',
            style: theme.textTheme.muted,
          ),
        ),
        ShadPaginationCompact(
          page: page + 1,
          pageCount: pageCount,
          onPageChanged: (value) => onPageChanged(value - 1),
        ),
      ],
    );
  }
}

/// A label and value pair in a definition list.
class AdminDetailRow extends StatelessWidget {
  const AdminDetailRow({super.key, required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 180, child: Text(label, style: theme.textTheme.muted)),
        Expanded(
          child: DefaultTextStyle.merge(
            style: theme.textTheme.small,
            child: value,
          ),
        ),
      ],
    );
  }
}
