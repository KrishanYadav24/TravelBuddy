import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_buddy/main.dart';

void main() {
  testWidgets('TravelBuddyApp loads onboarding route smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TravelBuddyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Onboarding Screen'), findsWidgets);
  });
}
