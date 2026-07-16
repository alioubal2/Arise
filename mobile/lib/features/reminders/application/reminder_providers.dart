import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/repositories/reminder_repository.dart';

/// Instance unique de la base de données pour toute l'app.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Repository des rappels.
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepository(ref.watch(appDatabaseProvider));
});

/// Flux réactif de la liste des rappels (alimente l'écran Accueil).
final remindersStreamProvider = StreamProvider<List<Reminder>>((ref) {
  return ref.watch(reminderRepositoryProvider).watchReminders();
});

/// Un rappel unique par identifiant (pour l'écran d'édition).
final reminderProvider =
    FutureProvider.family<Reminder?, int>((ref, id) async {
  return ref.watch(reminderRepositoryProvider).getReminder(id);
});
