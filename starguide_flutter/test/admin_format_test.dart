import 'package:flutter_test/flutter_test.dart';
import 'package:starguide_client/starguide_client.dart';
import 'package:starguide_flutter/admin/admin_format.dart';

void main() {
  test('formatCompactCount shortens large numbers', () {
    expect(formatCompactCount(0), '0');
    expect(formatCompactCount(999), '999');
    expect(formatCompactCount(1234), '1.2k');
    expect(formatCompactCount(12345), '12.3k');
    expect(formatCompactCount(3400000), '3.4M');
  });

  test('formatCount uses thousands separators', () {
    expect(formatCount(1234567), '1,234,567');
  });

  test('formatDuration uses the largest whole unit', () {
    expect(formatDuration(const Duration(minutes: 1)), '1 min');
    expect(formatDuration(const Duration(minutes: 45)), '45 min');
    expect(formatDuration(const Duration(hours: 1)), '1 hour');
    expect(formatDuration(const Duration(hours: 5)), '5 hours');
    expect(formatDuration(const Duration(days: 3)), '3 days');
  });

  test('formatRelative is relative to now', () {
    final now = DateTime.utc(2026, 9, 8, 12);
    expect(formatRelative(now, now: now), 'just now');
    expect(
      formatRelative(now.subtract(const Duration(minutes: 5)), now: now),
      '5 min ago',
    );
    expect(
      formatRelative(now.add(const Duration(hours: 2)), now: now),
      'in 2 hours',
    );
  });

  test('formatBytes picks the largest unit', () {
    expect(formatBytes(512), '512 B');
    expect(formatBytes(15300), '15.3 kB');
    expect(formatBytes(2500000), '2.5 MB');
  });

  test('formatGotHelpRatio handles missing votes', () {
    expect(
      formatGotHelpRatio(
        VoteStats(
          sessionCount: 10,
          goodAnswerCount: 0,
          poorAnswerCount: 0,
          answeredCount: 0,
          notAnsweredCount: 0,
          unsureCount: 0,
        ),
      ),
      '–',
    );
    expect(
      formatGotHelpRatio(
        VoteStats(
          sessionCount: 10,
          goodAnswerCount: 3,
          poorAnswerCount: 1,
          answeredCount: 0,
          notAnsweredCount: 0,
          unsureCount: 0,
        ),
      ),
      '75%',
    );
  });
}
