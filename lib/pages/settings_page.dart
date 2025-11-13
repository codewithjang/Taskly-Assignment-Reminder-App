import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../providers/assignment_provider.dart';
import 'package:numberpicker/numberpicker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SettingsProvider>().load());
  }

  // ----------------------------------------------------------
  // CONFIRM RESET
  // ----------------------------------------------------------
  Future<void> _confirmReset(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "ยืนยันการล้างข้อมูล",
          style: TextStyle(fontFamily: 'Prompt'),
        ),
        content: const Text(
          "การล้างข้อมูลจะเป็นการลบงานทั้งหมด และรีเซ็ตทุกอย่างกลับเป็นค่าเริ่มต้น\nต้องการดำเนินการต่อหรือไม่?",
          style: TextStyle(fontFamily: 'Prompt'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "ยกเลิก",
              style: TextStyle(fontFamily: 'Prompt'),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "ล้างข้อมูล",
              style: TextStyle(fontFamily: 'Prompt'),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final storage = StorageService();
    await storage.clearAll();

    await context.read<AssignmentProvider>().reload();
    await context.read<SettingsProvider>().resetToDefault();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("ล้างข้อมูลเสร็จสิ้น"),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ----------------------------------------------------------
  // PICK ADVANCE TIME
  // ----------------------------------------------------------
  Future<void> _pickCustomAdvanceTime() async {
    int days = 0;
    int hours = 1;
    int minutes = 0;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "ตั้งค่าการแจ้งเตือนล่วงหน้า",
          style: TextStyle(fontFamily: 'Prompt'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("เลือกเวลา:", style: TextStyle(fontFamily: 'Prompt')),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _timePickerColumn("วัน", days, 0, 30,
                    (v) => setState(() => days = v)),
                _timePickerColumn("ชั่วโมง", hours, 0, 23,
                    (v) => setState(() => hours = v)),
                _timePickerColumn("นาที", minutes, 0, 59,
                    (v) => setState(() => minutes = v)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("ยกเลิก", style: TextStyle(fontFamily: 'Prompt')),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text("บันทึก", style: TextStyle(fontFamily: 'Prompt')),
            onPressed: () {
              int total = (days * 24 * 60) + (hours * 60) + minutes;
              context.read<SettingsProvider>().setAdvanceMinutes(total);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _timePickerColumn(
      String label, int value, int min, int max, Function(int) onChanged) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontFamily: 'Prompt')),
          NumberPicker(
            value: value,
            minValue: min,
            maxValue: max,
            textStyle:
                const TextStyle(fontFamily: 'Prompt', color: Colors.grey),
            selectedTextStyle: const TextStyle(
              fontFamily: 'Prompt',
              fontSize: 18,
              color: Color(0xFF0D47A1),
              fontWeight: FontWeight.bold,
            ),
            onChanged: (v) => onChanged(v),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'การตั้งค่า',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontFamily: 'Prompt',
            color: Colors.white,
          ),
        ),
      ),

      // ----------------------------------------------------------
      // BODY UI NEW DESIGN
      // ----------------------------------------------------------
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D47A1),
              Color(0xFF1976D2),
              Color(0xFFE3F2FD),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ------------------------ CARD 1 ------------------------
            _settingsCard(
              children: [
                SwitchListTile(
                  title: const Text(
                    'เปิดการแจ้งเตือน',
                    style: TextStyle(fontFamily: 'Prompt'),
                  ),
                  activeColor: const Color(0xFF0D47A1),
                  value: sp.notificationsEnabled,
                  onChanged: (v) async => sp.setNotificationsEnabled(v),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text(
                    "แจ้งเตือนล่วงหน้า",
                    style: TextStyle(fontFamily: 'Prompt'),
                  ),
                  subtitle: Text(
                    "${sp.advanceMinutes ~/ 1440} วัน "
                    "${(sp.advanceMinutes % 1440) ~/ 60} ชม. "
                    "${sp.advanceMinutes % 60} นาที",
                    style: const TextStyle(fontFamily: 'Prompt'),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _pickCustomAdvanceTime,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ------------------------ CARD 2 ------------------------
            _settingsCard(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text(
                    "ล้างข้อมูลทั้งหมด (Reset App Data)",
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    "ลบงานทั้งหมด + รีเซ็ตการตั้งค่า",
                    style: TextStyle(fontFamily: 'Prompt'),
                  ),
                  onTap: () => _confirmReset(context),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ------------------------ TEST BUTTON ------------------------
            FilledButton.icon(
              onPressed: () => NotificationService.showTest(),
              icon: const Icon(Icons.notifications_active),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              label: const Text(
                'ทดสอบการแจ้งเตือน',
                style: TextStyle(fontFamily: 'Prompt', fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // REUSABLE SETTINGS CARD
  // ----------------------------------------------------------
  Widget _settingsCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.93),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
