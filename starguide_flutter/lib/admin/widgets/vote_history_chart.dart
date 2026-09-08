import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shad/shad.dart';
import 'package:starguide_client/starguide_client.dart';
import 'package:starguide_flutter/admin/admin_format.dart';

/// Colors used for the votes in the chart and its legend.
class VoteColors {
  const VoteColors({
    required this.gotHelp,
    required this.poorAnswer,
    required this.noVote,
  });

  factory VoteColors.of(BuildContext context) {
    final colorScheme = ShadTheme.of(context).colorScheme;
    return VoteColors(
      gotHelp: const Color(0xFF16A34A),
      poorAnswer: colorScheme.destructive,
      noVote: colorScheme.border,
    );
  }

  final Color gotHelp;
  final Color poorAnswer;
  final Color noVote;
}

/// A stacked bar chart of chat sessions per day, split by vote. Hovering a
/// bar shows the counts of that day.
class VoteHistoryChart extends StatefulWidget {
  const VoteHistoryChart({super.key, required this.stats, this.height = 220});

  /// One entry per day, oldest first.
  final List<DailyStats> stats;
  final double height;

  @override
  State<VoteHistoryChart> createState() => _VoteHistoryChartState();
}

class _VoteHistoryChartState extends State<VoteHistoryChart> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colors = VoteColors.of(context);
    final labelStyle = theme.textTheme.muted.copyWith(fontSize: 11);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            _LegendItem(color: colors.gotHelp, label: 'Got Help'),
            _LegendItem(color: colors.poorAnswer, label: 'Poor Answer'),
            _LegendItem(color: colors.noVote, label: 'No vote'),
          ],
        ),
        SizedBox(
          height: widget.height,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final geometry = _ChartGeometry(
                size: Size(constraints.maxWidth, widget.height),
                dayCount: widget.stats.length,
              );
              final hovered = _hoveredIndex == null
                  ? null
                  : widget.stats[_hoveredIndex!];

              void updateHover(Offset position) {
                final index = geometry.indexAt(position.dx);
                if (index != _hoveredIndex) {
                  setState(() => _hoveredIndex = index);
                }
              }

              return MouseRegion(
                onEnter: (event) => updateHover(event.localPosition),
                onHover: (event) => updateHover(event.localPosition),
                onExit: (_) => setState(() => _hoveredIndex = null),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _VoteHistoryPainter(
                          stats: widget.stats,
                          geometry: geometry,
                          colors: colors,
                          gridColor: theme.colorScheme.border,
                          labelStyle: labelStyle,
                          hoveredIndex: _hoveredIndex,
                          highlightColor: theme.colorScheme.muted,
                        ),
                      ),
                    ),
                    if (hovered != null)
                      Positioned(
                        top: 0,
                        left: geometry.tooltipLeft(_hoveredIndex!),
                        child: _DayTooltip(stats: hovered),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(label, style: theme.textTheme.muted),
      ],
    );
  }
}

class _DayTooltip extends StatelessWidget {
  const _DayTooltip({required this.stats});

  final DailyStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final noVote =
        stats.sessionCount - stats.goodAnswerCount - stats.poorAnswerCount;
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.popover,
          border: Border.all(color: theme.colorScheme.border),
          borderRadius: theme.radii.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(formatShortDate(stats.day), style: theme.textTheme.small),
            Text(
              '${stats.sessionCount} sessions',
              style: theme.textTheme.muted,
            ),
            Text(
              '${stats.goodAnswerCount} got help · '
              '${stats.poorAnswerCount} poor · $noVote no vote',
              style: theme.textTheme.muted,
            ),
          ],
        ),
      ),
    );
  }
}

/// The layout of the chart: where the plot area is and how wide a day is.
class _ChartGeometry {
  _ChartGeometry({required this.size, required this.dayCount});

  final Size size;
  final int dayCount;

  static const _left = 36.0;
  static const _right = 8.0;
  static const _top = 12.0;
  static const _bottom = 22.0;

  Rect get plot =>
      Rect.fromLTRB(_left, _top, size.width - _right, size.height - _bottom);

  double get dayWidth => dayCount == 0 ? 0 : plot.width / dayCount;

  /// Horizontal extent of the bar of day [index].
  Rect columnAt(int index) {
    final left = plot.left + index * dayWidth;
    return Rect.fromLTRB(left, plot.top, left + dayWidth, plot.bottom);
  }

  int? indexAt(double dx) {
    if (dayCount == 0 || dx < plot.left || dx >= plot.right) return null;
    return ((dx - plot.left) / dayWidth).floor().clamp(0, dayCount - 1);
  }

  /// Places the tooltip next to the hovered day, flipping it to the left of
  /// the bar on the right half of the chart so it stays inside the plot.
  double tooltipLeft(int index) {
    const tooltipWidth = 200.0;
    final column = columnAt(index);
    if (column.center.dx + tooltipWidth + 8 < plot.right) {
      return column.right + 4;
    }
    return math.max(plot.left, column.left - tooltipWidth - 4);
  }
}

class _VoteHistoryPainter extends CustomPainter {
  _VoteHistoryPainter({
    required this.stats,
    required this.geometry,
    required this.colors,
    required this.gridColor,
    required this.labelStyle,
    required this.hoveredIndex,
    required this.highlightColor,
  });

  final List<DailyStats> stats;
  final _ChartGeometry geometry;
  final VoteColors colors;
  final Color gridColor;
  final TextStyle labelStyle;
  final int? hoveredIndex;
  final Color highlightColor;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = geometry.plot;
    final maxCount = stats.fold(0, (max, s) => math.max(max, s.sessionCount));
    final scaleMax = _niceMax(maxCount);

    // Highlight the hovered day.
    if (hoveredIndex != null) {
      canvas.drawRect(
        geometry.columnAt(hoveredIndex!),
        Paint()..color = highlightColor,
      );
    }

    // Horizontal grid lines with their values.
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    const gridLines = 4;
    for (var i = 0; i <= gridLines; i++) {
      final value = scaleMax * i / gridLines;
      final y = plot.bottom - plot.height * i / gridLines;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      _paintLabel(
        canvas,
        value.round().toString(),
        Offset(plot.left - 6, y),
        alignment: Alignment.centerRight,
      );
    }

    // One stacked bar per day.
    final barInset = geometry.dayWidth * 0.15;
    for (var i = 0; i < stats.length; i++) {
      final day = stats[i];
      final column = geometry.columnAt(i);
      final left = column.left + barInset;
      final right = column.right - barInset;
      var bottom = plot.bottom;

      void segment(int count, Color color) {
        if (count <= 0) return;
        final height = plot.height * count / scaleMax;
        canvas.drawRect(
          Rect.fromLTRB(left, bottom - height, right, bottom),
          Paint()..color = color,
        );
        bottom -= height;
      }

      segment(day.goodAnswerCount, colors.gotHelp);
      segment(day.poorAnswerCount, colors.poorAnswer);
      segment(
        day.sessionCount - day.goodAnswerCount - day.poorAnswerCount,
        colors.noVote,
      );
    }

    // Date labels, spaced so they do not overlap.
    final labelEvery = math.max(1, (stats.length / 6).ceil());
    for (var i = 0; i < stats.length; i++) {
      if (i % labelEvery != 0 && i != stats.length - 1) continue;
      _paintLabel(
        canvas,
        formatShortDate(stats[i].day),
        Offset(geometry.columnAt(i).center.dx, plot.bottom + 4),
        alignment: Alignment.topCenter,
      );
    }
  }

  /// A round upper bound for the value axis.
  static int _niceMax(int maxCount) {
    if (maxCount <= 4) return 4;
    final magnitude = math.pow(10, (math.log(maxCount) / math.ln10).floor());
    for (final factor in [1, 2, 4, 5, 10]) {
      final candidate = (magnitude * factor).toInt();
      if (candidate >= maxCount) return candidate;
    }
    return maxCount;
  }

  void _paintLabel(
    Canvas canvas,
    String text,
    Offset anchor, {
    required Alignment alignment,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: labelStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = Offset(
      anchor.dx - painter.width * (alignment.x + 1) / 2,
      anchor.dy - painter.height * (alignment.y + 1) / 2,
    );
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_VoteHistoryPainter oldDelegate) {
    return stats != oldDelegate.stats ||
        hoveredIndex != oldDelegate.hoveredIndex ||
        geometry.size != oldDelegate.geometry.size ||
        labelStyle != oldDelegate.labelStyle;
  }
}
