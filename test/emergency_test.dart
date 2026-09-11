import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_buddy/core/widgets/sos_floating_button.dart';
import 'package:travel_buddy/features/emergency/emergency_screen.dart';
import 'package:travel_buddy/features/emergency/services/emergency_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Emergency Feature Tests', () {
    testWidgets('EmergencyService copyCoordinates sends formatted GPS coordinates to Clipboard', (tester) async {
      final List<MethodCall> log = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.setData') {
            log.add(methodCall);
          }
          return null;
        },
      );

      await EmergencyService.copyCoordinates(30.7268, 78.4354);

      expect(log, hasLength(1));
      expect(log.single.method, 'Clipboard.setData');
      expect(log.single.arguments['text'], contains('30.7268° N, 78.4354° E'));
    });

    testWidgets('EmergencyScreen renders SOS title, GPS panel, call buttons, and hospital card', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EmergencyScreen(
            latitude: 30.7268,
            longitude: 78.4354,
            destinationName: 'Kedarkantha Peak',
          ),
        ),
      );

      // Verify Header
      expect(find.text('SOS Emergency Assistance'), findsOneWidget);

      // Verify GPS Location Panel
      expect(find.textContaining('Current Location (Kedarkantha Peak)'), findsOneWidget);
      expect(find.text('30.7268° N, 78.4354° E'), findsOneWidget);
      expect(find.text('Copy GPS'), findsOneWidget);
      expect(find.text('Share Location'), findsOneWidget);

      // Verify Emergency Helplines
      expect(find.text('CALL LOCAL POLICE'), findsOneWidget);
      expect(find.text('FOREST DEPT HELPLINE'), findsOneWidget);
      expect(find.text('DISASTER MANAGEMENT'), findsOneWidget);

      // Verify Nearest Hospital Card
      expect(find.text('District Hospital Uttarkashi'), findsOneWidget);
      expect(find.text('Call Hospital'), findsOneWidget);
      expect(find.text('Directions'), findsOneWidget);

      // Verify Safety Protocol
      expect(find.text('Offline Mountain SOS Protocol'), findsOneWidget);
    });

    testWidgets('SosFloatingButton renders with danger icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            floatingActionButton: SosFloatingButton(),
          ),
        ),
      );

      expect(find.byType(SosFloatingButton), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });
  });
}
