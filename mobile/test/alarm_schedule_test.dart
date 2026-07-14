// Tests de la logique de prochaine occurrence d'alarme.

import 'package:arise/data/models/recurrence.dart';
import 'package:arise/features/alarm/domain/alarm_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('computeNextOccurrence', () {
    test('quotidien : aujourd\'hui si l\'heure est à venir', () {
      final now = DateTime(2026, 7, 14, 6, 0); // mardi 6h
      final next = computeNextOccurrence(
        now: now,
        hour: 7,
        minute: 30,
        type: RecurrenceType.daily,
      );
      expect(next, DateTime(2026, 7, 14, 7, 30));
    });

    test('quotidien : demain si l\'heure est passée', () {
      final now = DateTime(2026, 7, 14, 8, 0);
      final next = computeNextOccurrence(
        now: now,
        hour: 7,
        minute: 30,
        type: RecurrenceType.daily,
      );
      expect(next, DateTime(2026, 7, 15, 7, 30));
    });

    test('une fois : prochaine occurrence de l\'heure', () {
      final now = DateTime(2026, 7, 14, 23, 0);
      final next = computeNextOccurrence(
        now: now,
        hour: 7,
        minute: 0,
        type: RecurrenceType.once,
      );
      expect(next, DateTime(2026, 7, 15, 7, 0));
    });

    test('jours choisis : prochain jour sélectionné', () {
      // Mardi 14 juillet 2026, 8h. Rappel les lundi et vendredi à 7h.
      final now = DateTime(2026, 7, 14, 8, 0);
      final next = computeNextOccurrence(
        now: now,
        hour: 7,
        minute: 0,
        type: RecurrenceType.weekdays,
        weekdays: {Weekday.monday, Weekday.friday},
      );
      // Prochain vendredi = 17 juillet 2026.
      expect(next, DateTime(2026, 7, 17, 7, 0));
    });

    test('jours choisis : aujourd\'hui si le jour correspond et l\'heure à venir',
        () {
      final now = DateTime(2026, 7, 14, 6, 0); // mardi 6h
      final next = computeNextOccurrence(
        now: now,
        hour: 7,
        minute: 0,
        type: RecurrenceType.weekdays,
        weekdays: {Weekday.tuesday},
      );
      expect(next, DateTime(2026, 7, 14, 7, 0));
    });

    test('jours choisis : semaine suivante si le seul jour est déjà passé', () {
      final now = DateTime(2026, 7, 14, 8, 0); // mardi 8h, après 7h
      final next = computeNextOccurrence(
        now: now,
        hour: 7,
        minute: 0,
        type: RecurrenceType.weekdays,
        weekdays: {Weekday.tuesday},
      );
      expect(next, DateTime(2026, 7, 21, 7, 0)); // mardi suivant
    });
  });
}
