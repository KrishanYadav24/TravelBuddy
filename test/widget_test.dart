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

    // Pump frame for initial widget tree build
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Discover India, your way'), findsWidgets);
    expect(find.text('Skip'), findsOneWidget);
  });
}
