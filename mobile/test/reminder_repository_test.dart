// Tests unitaires du repository sur une base Drift en mémoire.

import 'package:arise/data/database/app_database.dart';
import 'package:arise/data/models/math_difficulty.dart';
import 'package:arise/data/models/recurrence.dart';
import 'package:arise/data/repositories/reminder_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ReminderRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ReminderRepository(db);
  });

  tearDown(() => db.close());

  test('createReminder enregistre puis watchReminders émet le rappel',
      () async {
    await repo.createReminder(
      title: 'Sport',
      hour: 18,
      minute: 0,
      recurrenceType: RecurrenceType.daily,
      mathDifficulty: MathDifficulty.medium,
    );

    final list = await repo.watchReminders().first;

    expect(list, hasLength(1));
    expect(list.first.title, 'Sport');
    expect(list.first.formattedTime, '18:00');
    expect(list.first.difficulty, MathDifficulty.medium);
  });

  test('les rappels sont triés par heure croissante', () async {
    await repo.createReminder(
        title: 'Soir', hour: 20, minute: 0, recurrenceType: RecurrenceType.once);
    await repo.createReminder(
        title: 'Matin', hour: 6, minute: 30, recurrenceType: RecurrenceType.once);

    final list = await repo.watchReminders().first;

    expect(list.map((r) => r.title).toList(), ['Matin', 'Soir']);
  });

  test('setEnabled bascule l\'état actif', () async {
    final id = await repo.createReminder(
        title: 'Médicament',
        hour: 9,
        minute: 0,
        recurrenceType: RecurrenceType.daily);

    await repo.setEnabled(id, enabled: false);

    final reminder = await repo.getReminder(id);
    expect(reminder!.enabled, isFalse);
  });

  test('le masque de jours encode/décode correctement les jours choisis',
      () async {
    final id = await repo.createReminder(
      title: 'Semaine',
      hour: 7,
      minute: 0,
      recurrenceType: RecurrenceType.weekdays,
      weekdays: {Weekday.monday, Weekday.wednesday, Weekday.friday},
    );

    final reminder = await repo.getReminder(id);
    expect(
      reminder!.selectedWeekdays,
      {Weekday.monday, Weekday.wednesday, Weekday.friday},
    );
  });

  test('deleteReminder supprime le rappel', () async {
    final id = await repo.createReminder(
        title: 'Temporaire',
        hour: 12,
        minute: 0,
        recurrenceType: RecurrenceType.once);

    await repo.deleteReminder(id);

    final list = await repo.watchReminders().first;
    expect(list, isEmpty);
  });
}
