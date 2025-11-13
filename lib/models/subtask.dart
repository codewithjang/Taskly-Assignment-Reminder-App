import 'package:hive/hive.dart';

part 'subtask.g.dart';

@HiveType(typeId: 2)
class Subtask extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isDone;

  Subtask({
    required this.title,
    this.isDone = false,
  });
}
