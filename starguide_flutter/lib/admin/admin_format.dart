import 'package:shad/shad.dart';
import 'package:starguide_client/starguide_client.dart';

/// Formatting helpers for the admin interface.

final _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
final _dateFormat = DateFormat('d MMM');
final _numberFormat = NumberFormat.decimalPattern();

/// A date and time in the local time zone, e.g. `2026-09-08 14:05`.
String formatDateTime(DateTime time) => _dateTimeFormat.format(time.toLocal());

/// A short date, e.g. `8 Sep`.
String formatShortDate(DateTime time) => _dateFormat.format(time.toLocal());

/// An integer with thousands separators.
String formatCount(int count) => _numberFormat.format(count);

/// A time relative to now, e.g. `3 hours ago` or `in 2 days`.
String formatRelative(DateTime time, {DateTime? now}) {
  final difference = time.difference(now ?? DateTime.now());
  final absolute = difference.abs();
  if (absolute < const Duration(minutes: 1)) return 'just now';

  final text = formatDuration(absolute);
  return difference.isNegative ? '$text ago' : 'in $text';
}

/// A duration in its largest whole unit, e.g. `3 days` or `45 minutes`.
String formatDuration(Duration duration) {
  String plural(int count, String unit) =>
      '$count $unit${count == 1 ? '' : 's'}';

  if (duration.inDays >= 1) return plural(duration.inDays, 'day');
  if (duration.inHours >= 1) return plural(duration.inHours, 'hour');
  return plural(duration.inMinutes, 'minute');
}

/// The share of voted sessions that got help, as a percentage. Returns a
/// dash when no votes have been cast.
String formatGotHelpRatio(VoteStats stats) {
  final voted = stats.goodAnswerCount + stats.poorAnswerCount;
  if (voted == 0) return '–';
  return '${(stats.goodAnswerCount / voted * 100).round()}%';
}

/// A human readable label for a document type.
String documentTypeLabel(RAGDocumentType type) => switch (type) {
  RAGDocumentType.documentation => 'Documentation',
  RAGDocumentType.discussion => 'Discussion',
  RAGDocumentType.issue => 'Issue',
};
