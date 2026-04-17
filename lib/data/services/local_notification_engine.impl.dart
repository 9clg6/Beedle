import 'package:beedle/domain/services/notification_scheduler.service.dart';
import 'package:beedle/foundation/logging/logger.dart';
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_init;
import 'package:timezone/timezone.dart' as tz;

/// Implémentation LocalNotificationEngine via `flutter_local_notifications` 21.x.
final class LocalNotificationEngineImpl implements LocalNotificationEngine {
  LocalNotificationEngineImpl() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final Log _log = Log.named('LocalNotificationEngine');

  bool _initialized = false;

  Future<void> init({
    required void Function(String payload) onTap,
  }) async {
    if (_initialized) return;
    tz_init.initializeTimeZones();

    const AndroidInitializationSettings android = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    // IMPORTANT : on désactive la demande de permissions à l'init pour que
    // le popup natif iOS ne se déclenche PAS au cold start. La permission
    // est demandée explicitement à l'étape 7 de l'onboarding via
    // `requestPermission()` — sinon iOS considère la demande comme déjà
    // résolue et ne ré-affiche jamais le popup au tap "Autoriser".
    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse resp) {
        final String? payload = resp.payload;
        if (payload != null) onTap(payload);
      },
    );
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    final bool? ios = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    final bool? android = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
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
    final tz.TZDateTime scheduled = tz.TZDateTime.from(at, tz.local);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'beedle_default',
          'Beedle',
          channelDescription: 'Teasers et rappels quotidiens Beedle',
          importance: Importance.high,
          priority: Priority.high,
          // ── Small icon (status bar) ──────────────────────────────────────
          // Android impose ici une silhouette monochrome (toute couleur est
          // strippée par l'OS depuis API 21). `ic_launcher_monochrome` est
          // généré par flutter_launcher_icons à partir de
          // `assets/branding/icon-notification-monochrome-1024.png`.
          icon: 'ic_launcher_monochrome',
          // Teinte la silhouette + le badge avec l'ember Beedle (#FF6B2E).
          color: Color(0xFFFF6B2E),
          colorized: true,
          // ── Large icon (corps de la notif) ───────────────────────────────
          // Affiche le Dot-b coloré (le vrai logo de l'app, source SVG
          // `assets/branding/icon-dot-b.svg`) à droite du contenu de la notif.
          largeIcon: DrawableResourceAndroidBitmap('ic_launcher'),
        );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
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
