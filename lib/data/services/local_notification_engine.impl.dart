import 'package:beedle/domain/services/notification_scheduler.service.dart';
import 'package:beedle/foundation/logging/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_init;
import 'package:timezone/timezone.dart' as tz;

/// Implémentation LocalNotificationEngine via `flutter_local_notifications` 21.x.
final class LocalNotificationEngineImpl implements LocalNotificationEngine {
  LocalNotificationEngineImpl()
      : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final Log _log = Log.named('LocalNotificationEngine');

  bool _initialized = false;

  Future<void> init({
    required void Function(String payload) onTap,
  }) async {
    if (_initialized) return;
    tz_init.initializeTimeZones();

    const android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (resp) {
        final payload = resp.payload;
        if (payload != null) onTap(payload);
      },
    );
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    final ios = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    final android = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return ios ?? android ?? false;
  }

  @override
  Future<void> scheduleAt({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required String payload,
  }) async {
    final scheduled = tz.TZDateTime.from(at, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'beedle_default',
      'Beedle',
      channelDescription: 'Teasers et rappels quotidiens Beedle',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: scheduled,
      title: title,
      body: body,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
    _log.info('Scheduled notif $id at $scheduled');
  }

  @override
  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
