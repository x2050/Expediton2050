import 'package:flutter_test/flutter_test.dart';
import 'package:expedition_aurelio/app.dart';

void main() {
  testWidgets('Expedition Aurelio starts',
      (WidgetTester tester) async {
    // Load the real Expedition Aurelio application.
    await tester.pumpWidget(const ExpeditionApp());

    // Confirm the application root is present.
    expect(find.byType(ExpeditionApp), findsOneWidget);
  });
}
