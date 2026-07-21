import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../../data/models/math_difficulty.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../alarm/application/alarm_scheduler.dart';
import '../../alarm/presentation/alarm_ringing_screen.dart';
import '../../math_lock/presentation/math_challenge_screen.dart';
import '../../photo_check/application/photo_service.dart';
import '../../settings/presentation/settings_screen.dart';
import '../application/reminder_providers.dart';
import 'reminder_edit_screen.dart';

/// Écran d'accueil : liste des rappels actifs et accès à la création.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(remindersStreamProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 64,
        title: Image.asset(
          'assets/logo/logo-03-transparent.png',
          height: 44,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            tooltip: 'Tester le calcul mental',
            icon: const Icon(Icons.calculate_outlined),
            onPressed: () => _openMathPreview(context),
          ),
          IconButton(
            tooltip: 'Réglages',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: remindersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Erreur de chargement des rappels :\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ),
        data: (reminders) {
          if (reminders.isEmpty) {
            return const _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: reminders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _ReminderCard(reminder: reminders[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau rappel'),
      ),
    );
  }

  void _openEditor(BuildContext context, {int? reminderId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ReminderEditScreen(reminderId: reminderId),
      ),
    );
  }

  /// Aperçu du calcul mental : choix du niveau puis lancement du défi.
  void _openMathPreview(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Tester le calcul mental',
                style: TextStyle(
                  color: AppColors.onDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            for (final level in MathDifficulty.values)
              ListTile(
                title: Text(level.label,
                    style: const TextStyle(color: AppColors.onDark)),
                subtitle: Text(
                  '${level.requiredStreak} bonne(s) réponse(s) · ${level.timeLimitSeconds}s',
                  style: const TextStyle(color: AppColors.onDarkMuted),
                ),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.onDarkMuted),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MathChallengeScreen(difficulty: level),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/logo/logo-02-transparent.png',
              width: 210,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 28),
            Text(
              'Aucun rappel pour le moment',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onDark,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Créez un rappel que vous devrez valider par une photo puis un calcul mental.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onDarkMuted, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderCard extends ConsumerWidget {
  const _ReminderCard({required this.reminder});

  final Reminder reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(reminderRepositoryProvider);
    final active = reminder.enabled;

    return Dismissible(
      key: ValueKey(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) async {
        await ref.read(alarmSchedulerProvider).cancel(reminder.id);
        await PhotoService().deleteReferencePhotos(reminder.referencePhotos);
        await repo.deleteReminder(reminder.id);
      },
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReminderEditScreen(reminderId: reminder.id),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.formattedTime,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? AppColors.onDark
                              : AppColors.onDarkMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        reminder.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          color: active
                              ? AppColors.onDark
                              : AppColors.onDarkMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.repeat,
                              size: 14, color: AppColors.onDarkMuted),
                          const SizedBox(width: 4),
                          Text(
                            reminder.recurrenceLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onDarkMuted,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.calculate_outlined,
                              size: 14, color: AppColors.onDarkMuted),
                          const SizedBox(width: 4),
                          Text(
                            reminder.difficulty.label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onDarkMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Tester l\'alarme',
                  icon: const Icon(Icons.play_circle_outline,
                      color: AppColors.secondary),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AlarmRingingScreen(reminder: reminder),
                    ),
                  ),
                ),
                Switch(
                  value: active,
                  activeThumbColor: AppColors.primary,
                  onChanged: (value) async {
                    await repo.setEnabled(reminder.id, enabled: value);
                    final updated = await repo.getReminder(reminder.id);
                    if (updated != null) {
                      await ref
                          .read(alarmSchedulerProvider)
                          .schedule(updated);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce rappel ?'),
        content: Text('« ${reminder.title} » sera définitivement supprimé.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
