import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:shad/shad.dart';
import 'package:starguide_client/starguide_client.dart';
import 'package:starguide_flutter/admin/admin_page.dart';
import 'package:starguide_flutter/admin/widgets/admin_widgets.dart';
import 'package:starguide_flutter/admin/widgets/vote_history_chart.dart';
import 'package:starguide_flutter/config/theme.dart';
import 'package:starguide_flutter/main.dart';

Widget _app(Widget home) {
  return ShadApp.custom(
    theme: ShadThemeData(),
    appBuilder: (context) => MaterialApp(
      theme: createTheme(),
      localizationsDelegates: const [GlobalShadLocalizations.delegate],
      builder: (context, child) => ShadAppBuilder(child: child!),
      home: home,
    ),
  );
}

void main() {
  setUpAll(() {
    // No server is running in tests, so every request fails and the views
    // end up in their error state.
    client = Client('http://localhost:1/');
    sessionManager = FlutterAuthSessionManager();
  });

  testWidgets('admin page shows the sidebar and switches views', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var closed = false;
    await tester.pumpWidget(_app(AdminPage(onClose: () => closed = true)));
    await tester.pump();

    expect(find.text('Overview'), findsWidgets);
    expect(find.text('Sources'), findsOneWidget);
    expect(find.text('Poor Answers'), findsOneWidget);
    expect(find.text('Document Index'), findsOneWidget);
    expect(find.text('Unanswered'), findsOneWidget);

    // The overview fails to load without a server.
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Failed to load data'), findsOneWidget);

    await tester.tap(find.text('Sources'));
    await tester.pump();
    expect(find.text('Search titles'), findsOneWidget);
    expect(find.text('All types'), findsOneWidget);

    await tester.tap(find.text('Poor Answers'));
    await tester.pump();
    expect(find.text('Poor Answer'), findsOneWidget);

    await tester.tap(find.text('Unanswered'));
    await tester.pump();
    expect(find.text('Not answered'), findsOneWidget);

    await tester.tap(find.text('Document Index'));
    await tester.pump();
    expect(find.text('Rebuild'), findsOneWidget);

    await tester.tap(find.text('Back to chat'));
    expect(closed, isTrue);
  });

  testWidgets('table card shows the empty message when there are no rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: AdminTableCard(
            emptyMessage: 'Nothing here',
            columnWidths: const [null],
            header: const [ShadTableCell.header(child: Text('Column'))],
            rows: const [],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Nothing here'), findsOneWidget);

    await tester.pumpWidget(
      _app(
        Scaffold(
          body: AdminTableCard(
            columnWidths: const [null],
            header: const [ShadTableCell.header(child: Text('Column'))],
            rows: const [
              [ShadTableCell(child: Text('Row 1'))],
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Row 1'), findsOneWidget);
    expect(find.text('Nothing here'), findsNothing);
  });

  testWidgets('vote history chart paints and shows a tooltip on hover', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final today = DateTime.utc(2026, 9, 8);
    final stats = [
      for (var i = 0; i < 30; i++)
        DailyStats(
          day: today.subtract(Duration(days: 29 - i)),
          sessionCount: i + 3,
          goodAnswerCount: i,
          poorAnswerCount: 1,
          answeredCount: i,
          notAnsweredCount: 1,
          unsureCount: 1,
        ),
    ];

    await tester.pumpWidget(
      _app(
        Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: VoteHistoryChart(stats: stats),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Got Help'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    // The plot is the chart's mouse region, below the legend.
    final plot = tester.getRect(find.byType(MouseRegion).last);
    await gesture.moveTo(plot.center);
    await tester.pump();

    expect(find.textContaining('sessions'), findsOneWidget);
    expect(find.textContaining('got help'), findsOneWidget);
  });
}
