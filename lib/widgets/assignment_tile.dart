import 'package:flutter/material.dart';
import '../models/assignment.dart';
import '../utils/dt_utils.dart';


class AssignmentTile extends StatelessWidget {
  final Assignment a;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleDone;


  const AssignmentTile({super.key, required this.a, required this.onTap, required this.onDelete, required this.onToggleDone});


  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: ListTile(
      leading: Checkbox(value: a.isDone, onChanged: (_) => onToggleDone()),
      title: Text(a.subject, style: TextStyle(decoration: a.isDone ? TextDecoration.lineThrough : null)),
      subtitle: Text('${a.details}\n${DtUtils.humanDate(a.dueAt)}'),
      isThreeLine: true,
      trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: onDelete),
      onTap: onTap,
      ),
    );
  }
}