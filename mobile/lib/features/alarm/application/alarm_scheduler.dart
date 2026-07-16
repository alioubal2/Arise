import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../domain/alarm_schedule.dart';
import 'notification_service.dart';

/// Programme / annule les alarmes des rappels via le service de notifications.
class AlarmScheduler {
  AlarmScheduler(this._notifications);

  final NotificationService _notifications;

  /// (Re)programme l'alarme d'un rappel. L'annule s'il est désactivé.
  Future<void> schedule(Reminder reminder) async {
    if (!reminder.enabled) {
      await _notifications.cancelReminder(reminder.id);
      return;
    }
    final next = computeNextOccurrence(
      now: DateTime.now(),
      hour: reminder.hour,
      minute: reminder.minute,
      type: reminder.recurrence,
      weekdays: reminder.selectedWeekdays,
    );
    await _notifications.scheduleAlarm(
      reminderId: reminder.id,
      title: reminder.title,
      when: next,
    );
    final prep = reminder.prepNotificationMinutes;
    if (prep != null) {
      await _notifications.schedulePrepNotification(
        reminderId: reminder.id,
        title: reminder.title,
        when: next,
        minutesBefore: prep,
      );
    }
  }

  Future<void> cancel(int reminderId) =>
      _notifications.cancelReminder(reminderId);

  /// Reprogramme tous les rappels (au démarrage de l'app).
  Future<void> rescheduleAll(List<Reminder> reminders) async {
    for (final reminder in reminders) {
      await schedule(reminder);
    }
  }
}

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService.instance);

final alarmSchedulerProvider = Provider<AlarmScheduler>(
  (ref) => AlarmScheduler(ref.watch(notificationServiceProvider)),
);
