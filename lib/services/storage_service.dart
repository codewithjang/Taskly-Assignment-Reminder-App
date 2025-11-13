import 'package:hive_flutter/hive_flutter.dart';
import '../models/assignment.dart';
import '../models/subtask.dart';   // ⭐ ต้อง import ด้วย

class StorageService {
  static const assignmentsBoxName = 'assignments_box';

  static Future<void> init() async {
    await Hive.initFlutter();

    // --- Register Adapters ให้ครบทุก model ---
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(AssignmentAdapter());
    }

    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SubtaskAdapter());
    }

    // ⭐ เปิดกล่องหลังจากลงทะเบียน adapter ทั้งหมดแล้ว
    await Hive.openBox<Assignment>(assignmentsBoxName);
  }

  Box<Assignment> get _box => Hive.box<Assignment>(assignmentsBoxName);

  List<Assignment> getAll() {
    final items = _box.values.toList();
    items.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    return items;
  }

  Future<void> put(Assignment assignment) async {
    await _box.put(assignment.id, assignment);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }

  Assignment? get(String id) => _box.get(id);
}
