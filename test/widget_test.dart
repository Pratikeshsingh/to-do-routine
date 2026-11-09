import 'package:flutter_test/flutter_test.dart';

import 'package:to_do_routine/app.dart';

void main() {
  testWidgets('boots to Schedule tab shell', (WidgetTester tester) async {
    await tester.pumpWidget(const DailyRoutineApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Current focus'), findsOneWidget);
    expect(find.text('Week template'), findsOneWidget);
    expect(find.text('To-Do'), findsOneWidget);
    expect(find.text('Summary'), findsOneWidget);
  });

  testWidgets('can switch to To-Do tab', (WidgetTester tester) async {
    await tester.pumpWidget(const DailyRoutineApp());
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('To-Do'));
    await tester.pumpAndSettle();

    expect(find.text('New task'), findsOneWidget);
  });
}
