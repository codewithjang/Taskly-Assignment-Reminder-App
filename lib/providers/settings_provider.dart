import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _kNotificationsEnabled = 'notifications_enabled';
  static const _kAdvanceMinutes = 'advance_minutes';

  bool _notificationsEnabled = true;
  int _advanceMinutes = 1440; // 1 วัน

  bool get notificationsEnabled => _notificationsEnabled;
  int get advanceMinutes => _advanceMinutes;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    _notificationsEnabled = sp.getBool(_kNotificationsEnabled) ?? true;
    _advanceMinutes = sp.getInt(_kAdvanceMinutes) ?? 1440;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kNotificationsEnabled, value);
    notifyListeners();
  }

  Future<void> setAdvanceMinutes(int minutes) async {
    _advanceMinutes = minutes;
    final sp = await SharedPreferences.getInstance();
    await sp.setInt(_kAdvanceMinutes, minutes);
    notifyListeners();
  }

  /// 🔥 ใช้เมธอดที่มีอยู่เพื่อรีเซ็ตค่า default
  Future<void> resetToDefault() async {
    await setNotificationsEnabled(true);
    await setAdvanceMinutes(1440); // default = 1 วัน
  }
}
