// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:creche_manager/main.dart';
import 'package:creche_manager/services/trial_service.dart';

void main() {
  testWidgets('TrialExpiredScreen renders expiration message', (
    WidgetTester tester,
  ) async {
    final trialResult = TrialResult(
      isExpired: true,
      isClockTampered: false,
      remainingDays: 0,
      remainingHours: 0,
    );

    await tester.pumpWidget(
      MaterialApp(home: TrialExpiredScreen(trialResult: trialResult)),
    );

    expect(find.text("Période d'essai expirée"), findsOneWidget);
    expect(find.byIcon(Icons.timer_off_rounded), findsOneWidget);
  });
}
