// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssignmentAdapter extends TypeAdapter<Assignment> {
  @override
  final int typeId = 1;

  @override
  Assignment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Assignment(
      id: fields[0] as String,
      subject: fields[1] as String,
      details: fields[2] as String,
      dueAt: fields[3] as DateTime,
      isDone: fields[4] as bool,
      category: fields[5] as String,
      tags: (fields[6] as List).cast<String>(),
      subtasks: (fields[7] as List).cast<Subtask>(),
      manualProgress: fields[8] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Assignment obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subject)
      ..writeByte(2)
      ..write(obj.details)
      ..writeByte(3)
      ..write(obj.dueAt)
      ..writeByte(4)
      ..write(obj.isDone)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.subtasks)
      ..writeByte(8)
      ..write(obj.manualProgress);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
