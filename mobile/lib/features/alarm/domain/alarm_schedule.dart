import '../../../data/models/recurrence.dart';

/// Calcule la prochaine occurrence d'un rappel à partir de [now].
///
/// Fonction pure (aucune dépendance système) pour être testable.
DateTime computeNextOccurrence({
  required DateTime now,
  required int hour,
  required int minute,
  required RecurrenceType type,
  Set<Weekday> weekdays = const {},
}) {
  DateTime at(int dayOffset) => DateTime(
        now.year,
        now.month,
        now.day + dayOffset,
        hour,
        minute,
      );

  switch (type) {
    case RecurrenceType.once:
    case RecurrenceType.daily:
      final today = at(0);
      return today.isAfter(now) ? today : at(1);

    case RecurrenceType.weekdays:
      if (weekdays.isEmpty) {
        final today = at(0);
        return today.isAfter(now) ? today : at(1);
      }
      // Cherche le prochain jour sélectionné (jusqu'à 7 jours), heure future.
      for (var offset = 0; offset < 8; offset++) {
        final candidate = at(offset);
        final day = Weekday.fromDateTime(candidate.weekday);
        if (weekdays.contains(day) && candidate.isAfter(now)) {
          return candidate;
        }
      }
      return at(7); // sécurité (ne devrait pas arriver)
  }
}
