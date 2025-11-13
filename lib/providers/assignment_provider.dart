import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/assignment.dart';
import 'package:uuid/uuid.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class AssignmentProvider extends ChangeNotifier {
  final StorageService storage;
  AssignmentProvider(this.storage);

  List<Assignment> _items = [];
  bool _showOnlyIncomplete = false;

  List<Assignment> get items =>
      _showOnlyIncomplete ? _items.where((a) => !a.isDone).toList() : _items;

  bool get showOnlyIncomplete => _showOnlyIncomplete;

  /// โหลดข้อมูลครั้งแรก (ตอนเปิดแอป)
  Future<void> load() async {
    _items = await storage.getAll(); // โหลดครั้งเดียว
    notifyListeners();
  }

  void setFilterIncomplete(bool value) {
    _showOnlyIncomplete = value;
    notifyListeners();
  }

  /// เพิ่มหรืออัปเดตงาน
  Future<void> addOrUpdate(
    Assignment a, {
    required int advanceMinutes,
    required bool notificationsEnabled,
  }) async {
    final isNew = _items.indexWhere((x) => x.id == a.id) == -1;

    // อัปเดต list ใน memory ก่อน (จะได้เห็นผลเร็ว)
    if (isNew) {
      _items.add(a);
    } else {
      final index = _items.indexWhere((x) => x.id == a.id);
      if (index != -1) _items[index] = a;
    }

    notifyListeners(); // อัปเดต UI ก่อน

    // ทำ I/O ภายหลัง (ไม่บล็อก main thread)
    Future(() async {
      await storage.put(a);

      final nid = _toNotificationId(a.id);
      await NotificationService.cancel(nid);

      if (notificationsEnabled) {
        final scheduleAt = a.dueAt.subtract(Duration(minutes: advanceMinutes));
        await NotificationService.schedule(
          id: nid,
          title: '📚 ${a.subject}',
          body: 'กำหนดส่ง ${_fmt(a.dueAt)} ใกล้เข้ามา',
          scheduledAt: scheduleAt,
        );
      }
    });
  }

  /// ลบงาน
  Future<void> remove(String id) async {
    _items.removeWhere((a) => a.id == id);
    notifyListeners();

    // ทำงานลบจริงใน background
    Future(() async {
      await NotificationService.cancel(_toNotificationId(id));
      await storage.delete(id);
    });
  }

  /// เปลี่ยนสถานะเสร็จ / ยังไม่เสร็จ
  Future<void> toggleDone(Assignment a) async {
    a.isDone = !a.isDone;
    notifyListeners();

    Future(() async {
      await storage.put(a);
    });
  }

  Future<void> reload() async {
    items.clear();
    await load();
    notifyListeners();
  }

  static int _toNotificationId(String uuid) =>
      uuid.hashCode & 0x7fffffff; // positive 32-bit

  static String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  static String newId() => const Uuid().v4();
}
