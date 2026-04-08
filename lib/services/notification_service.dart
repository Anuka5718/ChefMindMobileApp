import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialise() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }

  // Get reminder days from shared preferences (default = 1)
  Future<int> getReminderDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('reminder_days') ?? 1;
  }

  // Save reminder days
  Future<void> setReminderDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_days', days);
  }

  // Schedule expiry notification
  Future<void> scheduleExpiryNotification({
    required int id,
    required String ingredientName,
    required DateTime expiryDate,
  }) async {
    final reminderDays = await getReminderDays();
    final notifyDate = expiryDate.subtract(Duration(days: reminderDays));

    // Only schedule if notify date is in the future
    if (notifyDate.isBefore(DateTime.now())) return;

    final scheduledDate = tz.TZDateTime.from(notifyDate, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'expiry_channel',
      'Expiry Alerts',
      channelDescription: 'Alerts for ingredients expiring soon',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    await _plugin.zonedSchedule(
      id,
      '⚠️ $ingredientName is expiring soon!',
      '$ingredientName expires in $reminderDays day(s). Use it before it goes bad!',
      scheduledDate,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cancel a notification
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  // Show immediate test notification
  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'expiry_channel',
      'Expiry Alerts',
      channelDescription: 'Alerts for ingredients expiring soon',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _plugin.show(
      0,
      '🍳 ChefMind Test Notification',
      'Notifications are working correctly!',
      const NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

// Provider for reminder days setting
final reminderDaysProvider = StateNotifierProvider<ReminderDaysNotifier, int>(
  (ref) => ReminderDaysNotifier(),
);

class ReminderDaysNotifier extends StateNotifier<int> {
  ReminderDaysNotifier() : super(1) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt('reminder_days') ?? 1;
  }

  Future<void> setDays(int days) async {
    state = days;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_days', days);
  }
}