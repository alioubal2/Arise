import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/alarm/application/alarm_scheduler.dart';
import 'features/alarm/presentation/alarm_ringing_screen.dart';
import 'features/reminders/application/reminder_providers.dart';
import 'features/reminders/presentation/home_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: AriseApp()));
}

class AriseApp extends ConsumerStatefulWidget {
  const AriseApp({super.key});

  @override
  ConsumerState<AriseApp> createState() => _AriseAppState();
}

class _AriseAppState extends ConsumerState<AriseApp> {
  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    final notifications = ref.read(notificationServiceProvider);
    notifications.onAlarmOpened = _openAlarm;
    await notifications.init();
    await notifications.requestPermissions();

    // Reprogramme toutes les alarmes actives au démarrage.
    final reminders = await ref.read(reminderRepositoryProvider).watchReminders().first;
    await ref.read(alarmSchedulerProvider).rescheduleAll(reminders);
  }

  Future<void> _openAlarm(int reminderId) async {
    final reminder =
        await ref.read(reminderRepositoryProvider).getReminder(reminderId);
    if (reminder == null) return;
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => AlarmRingingScreen(reminder: reminder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arise',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const HomeScreen(),
    );
  }
}
