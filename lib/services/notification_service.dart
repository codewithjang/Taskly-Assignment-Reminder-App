import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service สำหรับจัดการการแจ้งเตือนภายในแอป
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// เริ่มต้นระบบแจ้งเตือน (ควรเรียกใน main.dart ก่อน runApp)
  static Future<void> initialize() async {
    tz.initializeTimeZones();

    // ป้องกัน timezone error
    try {
      tz.setLocalLocation(tz.getLocation("Asia/Bangkok"));
    } catch (e) {
      print("Timezone error: $e");
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );

    await _plugin.initialize(initSettings);

    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.requestNotificationsPermission();
    }
  }
  
  /// ทดสอบแสดงการแจ้งเตือนทันที
  static Future<void> showTest() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'assignments_channel',
        'Assignments',
        channelDescription: 'Notifications for upcoming assignments',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.show(
      9999,
      '🔔 Test Notification',
      'This is a test from Assignment Reminder App',
      details,
    );
  }

  /// ตั้งเวลาแจ้งเตือนล่วงหน้า
  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    final tzTime = tz.TZDateTime.from(scheduledAt, tz.local);

    // ข้ามถ้าเวลาอยู่ในอดีต
    if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'assignments_channel',
        'Assignments',
        channelDescription: 'Notifications for upcoming assignments',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  /// ยกเลิกการแจ้งเตือนเฉพาะ id
  static Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  /// ยกเลิกการแจ้งเตือนทั้งหมด
  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
