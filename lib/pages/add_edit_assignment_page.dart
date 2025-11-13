import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';
import '../models/subtask.dart';
import '../providers/assignment_provider.dart';
import '../providers/settings_provider.dart';

class AddEditAssignmentPage extends StatefulWidget {
  final Assignment? existing;
  const AddEditAssignmentPage({super.key, this.existing});

  @override
  State<AddEditAssignmentPage> createState() => _AddEditAssignmentPageState();
}

class _AddEditAssignmentPageState extends State<AddEditAssignmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();

  DateTime? _dueAt;
  bool _isDone = false;

  // CATEGORY
  final List<String> _categories = [
    "งานเดี่ยว",
    "งานกลุ่ม",
    "รายงาน",
    "งานเขียนโปรแกรม",
    "งานสอบ",
  ];
  String _selectedCategory = "งานเดี่ยว";

  // TAGS
  final List<String> _availableTags = [
    "Urgent",
    "Important",
    "Presentation",
    "Midterm",
    "Final",
  ];
  List<String> _selectedTags = [];

  // SUBTASKS
  List<Subtask> _subtasks = [];

  // PROGRESS MODE
  bool _useSubtaskProgress = true;
  double _manualProgress = 0.0;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    if (ex != null) {
      _subjectCtrl.text = ex.subject;
      _detailsCtrl.text = ex.details;
      _dueAt = ex.dueAt;
      _isDone = ex.isDone;

      _selectedCategory = ex.category;
      _selectedTags = List.from(ex.tags);
      _subtasks = List.from(ex.subtasks);

      if (ex.manualProgress != null) {
        _useSubtaskProgress = false;
        _manualProgress = ex.manualProgress!;
      }
    }
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  // --------------------------
  // PICK DATE + TIME
  // --------------------------
  Future<void> _pickDueDateTime() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueAt ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueAt ?? now),
    );
    if (pickedTime == null) return;

    setState(() {
      _dueAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  // --------------------------
  // AUTO PROGRESS FROM SUBTASKS
  // --------------------------
  double _calculateSubtaskProgress() {
    if (_subtasks.isEmpty) return 0.0;
    final doneCount = _subtasks.where((s) => s.isDone).length;
    return doneCount / _subtasks.length;
  }

  // --------------------------
  // SAVE ASSIGNMENT
  // --------------------------
  void _onSave(BuildContext context) async {
    if (_subjectCtrl.text.isEmpty || _dueAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบถ้วน')),
      );
      return;
    }

    final newAssignment = Assignment(
      id: widget.existing?.id ?? AssignmentProvider.newId(),
      subject: _subjectCtrl.text.trim(),
      details: _detailsCtrl.text.trim(),
      dueAt: _dueAt!,
      isDone: _isDone,
      category: _selectedCategory,
      tags: _selectedTags,
      subtasks: _subtasks,
      manualProgress: _useSubtaskProgress ? null : _manualProgress,
    );

    final settings = context.read<SettingsProvider>();

    await context.read<AssignmentProvider>().addOrUpdate(
          newAssignment,
          advanceMinutes: settings.advanceMinutes,
          notificationsEnabled: settings.notificationsEnabled,
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    // จัดธีม
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        title: Text(
          isEdit ? 'แก้ไขงาน' : 'เพิ่มงานใหม่',
          style: const TextStyle(fontFamily: 'Prompt'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ------------------- MAIN CARD -------------------
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // SUBJECT
                    TextFormField(
                      controller: _subjectCtrl,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อวิชา *',
                        labelStyle: TextStyle(fontFamily: 'Prompt'),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'กรอกชื่อวิชา' : null,
                    ),
                    const SizedBox(height: 14),

                    // DETAILS
                    TextFormField(
                      controller: _detailsCtrl,
                      minLines: 2,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'รายละเอียดของงาน',
                        labelStyle: TextStyle(fontFamily: 'Prompt'),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // CATEGORY
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                      decoration: const InputDecoration(
                        labelText: "ประเภทงาน",
                        labelStyle: TextStyle(fontFamily: 'Prompt'),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // TAGS
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "แท็กงาน",
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _availableTags.map((tag) {
                        final selected = _selectedTags.contains(tag);
                        return FilterChip(
                          label: Text(tag,
                              style: const TextStyle(fontFamily: 'Prompt')),
                          selected: selected,
                          selectedColor: const Color(0xFFBBDEFB),
                          onSelected: (_) {
                            setState(() {
                              selected
                                  ? _selectedTags.remove(tag)
                                  : _selectedTags.add(tag);
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // DUE DATE / TIME
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        _dueAt == null
                            ? 'เลือกวันและเวลา “กำหนดส่ง”'
                            : DateFormat('EEE, d MMM yyyy • HH:mm')
                                .format(_dueAt!),
                        style: const TextStyle(fontFamily: 'Prompt'),
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: _pickDueDateTime,
                    ),

                    const Divider(height: 26),

                    // PROGRESS
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Progress",
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SwitchListTile(
                      title: const Text(
                        "ใช้ progress จาก subtasks",
                        style: TextStyle(fontFamily: 'Prompt'),
                      ),
                      activeColor: const Color(0xFF0D47A1),
                      value: _useSubtaskProgress,
                      onChanged: (v) => setState(() => _useSubtaskProgress = v),
                    ),

                    // AUTO PROGRESS VIEW
                    if (_useSubtaskProgress)
                      Column(
                        children: [
                          const SizedBox(height: 6),
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 350),
                            tween: Tween<double>(
                                begin: 0.0, end: _calculateSubtaskProgress()),
                            builder: (_, value, __) {
                              return LinearProgressIndicator(
                                value: value,
                                minHeight: 6,
                                color: const Color(0xFF42A5F5),
                                backgroundColor: Colors.grey.shade200,
                              );
                            },
                          ),
                        ],
                      ),

                    // MANUAL PROGRESS
                    if (!_useSubtaskProgress)
                      Slider(
                        value: _manualProgress,
                        activeColor: const Color(0xFF0D47A1),
                        onChanged: (v) => setState(() => _manualProgress = v),
                      ),

                    const Divider(height: 26),

                    // --------------------------
                    // SUBTASK SECTION
                    // --------------------------
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "งานย่อย (Subtasks)",
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // LIST
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _subtasks.length,
                      itemBuilder: (context, index) {
                        final sub = _subtasks[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: sub.isDone,
                                activeColor: const Color(0xFF0D47A1),
                                onChanged: (v) {
                                  setState(() {
                                    sub.isDone = v!;
                                  });
                                },
                              ),
                              Expanded(
                                child: TextFormField(
                                  initialValue: sub.title,
                                  style: const TextStyle(fontFamily: 'Prompt'),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "ชื่องานย่อย",
                                    hintStyle: TextStyle(fontFamily: 'Prompt'),
                                  ),
                                  onChanged: (v) => sub.title = v,
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.close,
                                    color: Colors.red),
                                onPressed: () {
                                  setState(() => _subtasks.removeAt(index));
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 6),

                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF0D47A1),
                      ),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text(
                        "เพิ่มงานย่อย",
                        style: TextStyle(fontFamily: 'Prompt'),
                      ),
                      onPressed: () {
                        setState(() {
                          _subtasks.add(Subtask(title: ""));
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    // DONE
                    SwitchListTile(
                      title: const Text(
                        'เสร็จแล้ว',
                        style: TextStyle(fontFamily: 'Prompt'),
                      ),
                      activeColor: const Color(0xFF0D47A1),
                      value: _isDone,
                      onChanged: (v) => setState(() => _isDone = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ------------------- SAVE BUTTON -------------------
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _onSave(context),
                child: Text(
                  isEdit ? 'อัปเดต' : 'บันทึก',
                  style: const TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
