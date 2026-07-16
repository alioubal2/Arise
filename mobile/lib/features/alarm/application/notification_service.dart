import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Service de notifications locales et de planification des alarmes.
///
/// 100% local : programmation via `flutter_local_notifications`, aucune
/// dépendance réseau. L'alarme utilise un full-screen intent pour s'afficher
/// par-dessus l'écran verrouillé.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Rappelé avec l'identifiant du rappel quand l'utilisateur ouvre l'alarme.
  void Function(int reminderId)? onAlarmOpened;

  static const _alarmChannel = AndroidNotificationChannel(
    'arise_alarm',
    'Alarmes Arise',
    description: 'Déclenchement des rappels',
    importance: Importance.max,
    playSound: false, // le son est joué en plein écran par l'app
    enableVibration: false,
  );

  static const _infoChannel = AndroidNotificationChannel(
    'arise_info',
    'Notifications Arise',
    description: 'Préparation et confirmations',
    importance: Importance.high,
  );

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: androidInit),
      onDidReceiveNotificationResponse: _handleResponse,
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_alarmChannel);
    await android?.createNotificationChannel(_infoChannel);

    // Si l'app a été lancée en tapant une notification d'alarme.
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      final payload = launch!.notificationResponse?.payload;
      _routePayload(payload);
    }

    _initialized = true;
  }

  /// Demande les permissions sensibles (notifications, alarmes exactes).
  Future<void> requestPermissions() async {
    await Permission.notification.request();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestExactAlarmsPermission();
  }

  void _handleResponse(NotificationResponse response) =>
      _routePayload(response.payload);

  void _routePayload(String? payload) {
    if (payload == null) return;
    final id = int.tryParse(payload);
    if (id != null) onAlarmOpened?.call(id);
  }

  /// Programme l'alarme d'un rappel à l'instant donné (full-screen intent).
  Future<void> scheduleAlarm({
    required int reminderId,
    required String title,
    required DateTime when,
  }) async {
    final details = AndroidNotificationDetails(
      _alarmChannel.id,
      _alarmChannel.name,
      channelDescription: _alarmChannel.description,
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
      playSound: false,
      ongoing: true,
      autoCancel: false,
    );
    await _plugin.zonedSchedule(
      reminderId,
      'Arise — $title',
      "C'est l'heure : validez votre rappel.",
      tz.TZDateTime.from(when.toUtc(), tz.UTC),
      NotificationDetails(android: details),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: '$reminderId',
    );
  }

  /// Notification de préparation (ex. 10 min avant).
  Future<void> schedulePrepNotification({
    required int reminderId,
    required String title,
    required DateTime when,
    required int minutesBefore,
  }) async {
    final prepTime = when.subtract(Duration(minutes: minutesBefore));
    if (prepTime.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(
      _prepId(reminderId),
      'Bientôt : $title',
      'Votre rappel « $title » est dans $minutesBefore minutes.',
      tz.TZDateTime.from(prepTime.toUtc(), tz.UTC),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'arise_info',
          'Notifications Arise',
          channelDescription: 'Préparation et confirmations',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Confirmation après réussite complète des deux étapes.
  Future<void> showConfirmation(String title) async {
    await _plugin.show(
      99000,
      'Rappel validé ✓',
      '« $title » : bravo, vous êtes bien réveillé !',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'arise_info',
          'Notifications Arise',
          channelDescription: 'Préparation et confirmations',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> cancelReminder(int reminderId) async {
    await _plugin.cancel(reminderId);
    await _plugin.cancel(_prepId(reminderId));
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  int _prepId(int reminderId) => 500000 + reminderId;
}
