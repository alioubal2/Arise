// Smoke tests de l'écran d'accueil d'Arise.
//
// Le flux de rappels est surchargé par un Stream déterministe pour éviter la
// dépendance à la base et l'animation infinie du loader (qui bloque
// pumpAndSettle).

import 'package:arise/data/database/app_database.dart';
import 'package:arise/features/reminders/application/reminder_providers.dart';
import 'package:arise/features/reminders/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Reminder _sampleReminder() => Reminder(
      id: 1,
      title: 'Prière du matin',
      hour: 6,
      minute: 30,
      recurrenceType: 1, // daily
      weekdaysMask: 0,
      referencePhotos: const [],
      alarmSoundId: 'default',
      mathDifficulty: 0,
      prepNotificationMinutes: null,
      enabled: true,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

Future<void> _pumpHome(WidgetTester tester, List<Reminder> reminders) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        remindersStreamProvider.overrideWith((ref) => Stream.value(reminders)),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
  // Un pump pour construire, un autre pour laisser le Stream émettre.
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('Accueil : état vide quand aucun rappel', (tester) async {
    await _pumpHome(tester, const []);

    expect(find.text('Aucun rappel pour le moment'), findsOneWidget);
    expect(find.text('Nouveau rappel'), findsOneWidget);
  });

  testWidgets('Accueil : affiche un rappel', (tester) async {
    await _pumpHome(tester, [_sampleReminder()]);

    expect(find.text('06:30'), findsOneWidget);
    expect(find.text('Prière du matin'), findsOneWidget);
  });
}
