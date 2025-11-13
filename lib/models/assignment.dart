import 'package:hive/hive.dart';
import 'subtask.dart';

part 'assignment.g.dart';

@HiveType(typeId: 1)
class Assignment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String subject;

  @HiveField(2)
  String details;

  @HiveField(3)
  DateTime dueAt;

  @HiveField(4)
  bool isDone;

  // ---------------------------------------------------------
  // 🔵 ฟิลด์ใหม่สำหรับฟีเจอร์ 1: Category + Tags
  // ---------------------------------------------------------

  @HiveField(5)
  String category; // เช่น "งานเดี่ยว", "งานกลุ่ม", ...

  @HiveField(6)
  List<String> tags; // เช่น ["Urgent", "Presentation"]

  // ---------------------------------------------------------
  // 🔵 ฟิลด์ใหม่สำหรับฟีเจอร์ 3: Subtasks + Progress
  // ---------------------------------------------------------

  @HiveField(7)
  List<Subtask> subtasks;

  // ถ้า null = ใช้ progress จาก subtasks
  // ถ้าไม่ null = progress ที่ user ตั้งเอง (0.0–1.0)
  @HiveField(8)
  double? manualProgress;

  Assignment({
    required this.id,
    required this.subject,
    required this.details,
    required this.dueAt,
    this.isDone = false,
    this.category = "งานเดี่ยว",
    this.tags = const [],
    this.subtasks = const [],
    this.manualProgress,
  });

  double get progress {
    if (manualProgress != null) {
      return manualProgress!.clamp(0.0, 1.0);
    }

    if (subtasks.isEmpty) return isDone ? 1.0 : 0.0;

    final done = subtasks.where((t) => t.isDone).length;
    return (done / subtasks.length).clamp(0.0, 1.0);
  }
}
