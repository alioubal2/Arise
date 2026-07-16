import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../models/math_difficulty.dart';
import '../models/recurrence.dart';

/// Point d'accès unique aux rappels. Encapsule la base Drift pour que le reste
/// de l'app ne dépende pas directement des détails de persistance.
class ReminderRepository {
  ReminderRepository(this._db);

  final AppDatabase _db;

  Stream<List<Reminder>> watchReminders() => _db.watchReminders();

  Future<Reminder?> getReminder(int id) => _db.getReminder(id);

  Future<int> createReminder({
    required String title,
    required int hour,
    required int minute,
    required RecurrenceType recurrenceType,
    Set<Weekday> weekdays = const {},
    List<String> referencePhotos = const [],
    String alarmSoundId = 'default',
    MathDifficulty mathDifficulty = MathDifficulty.easy,
    int? prepNotificationMinutes,
  }) {
    final now = DateTime.now();
    return _db.insertReminder(
      RemindersCompanion.insert(
        title: title,
        hour: hour,
        minute: minute,
        recurrenceType: Value(recurrenceType.index),
        weekdaysMask: Value(weekdays.toMask()),
        referencePhotos: Value(referencePhotos),
        alarmSoundId: Value(alarmSoundId),
        mathDifficulty: Value(mathDifficulty.index),
        prepNotificationMinutes: Value(prepNotificationMinutes),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<bool> updateReminder(Reminder reminder) =>
      _db.updateReminder(reminder.copyWith(updatedAt: DateTime.now()));

  Future<int> deleteReminder(int id) => _db.deleteReminder(id);

  Future<int> setEnabled(int id, {required bool enabled}) =>
      _db.setEnabled(id, enabled);
}

/// Raccourcis de lecture typée sur l'entité générée par Drift.
extension ReminderX on Reminder {
  RecurrenceType get recurrence => RecurrenceType.fromIndex(recurrenceType);

  Set<Weekday> get selectedWeekdays => weekdaysFromMask(weekdaysMask);

  MathDifficulty get difficulty => MathDifficulty.fromIndex(mathDifficulty);

  /// Heure formatée en HH:mm.
  String get formattedTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// Description lisible de la récurrence.
  String get recurrenceLabel {
    switch (recurrence) {
      case RecurrenceType.once:
        return 'Une fois';
      case RecurrenceType.daily:
        return 'Tous les jours';
      case RecurrenceType.weekdays:
        final days = selectedWeekdays;
        if (days.isEmpty) return 'Aucun jour';
        // Ordre stable lundi -> dimanche.
        final ordered =
            Weekday.values.where(days.contains).map((d) => d.shortLabel);
        return ordered.join(' · ');
    }
  }
}
