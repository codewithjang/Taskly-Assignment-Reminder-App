import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../providers/assignment_provider.dart';
import '../models/assignment.dart';

import 'settings_page.dart';
import 'calendar_page.dart';
import 'add_edit_assignment_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchCtrl = TextEditingController();

  String? _filterCategory;
  String? _filterTag;
  bool _showOnlyIncomplete = false;

  List<String> _getAllTags(List<Assignment> items) {
    final setTags = <String>{};
    for (var a in items) {
      setTags.addAll(a.tags);
    }
    final list = setTags.toList()..sort();
    return list;
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AssignmentProvider>();
    final items = ap.items;
    final now = DateTime.now();

    // -------- FILTER + SEARCH ----------
    final query = _searchCtrl.text.trim().toLowerCase();

    final filtered = items.where((a) {
      if (query.isNotEmpty) {
        final hit = a.subject.toLowerCase().contains(query) ||
            a.details.toLowerCase().contains(query) ||
            a.category.toLowerCase().contains(query);
        if (!hit) return false;
      }

      if (_showOnlyIncomplete && a.isDone) return false;

      if (_filterCategory != null && a.category != _filterCategory) {
        return false;
      }

      if (_filterTag != null && !a.tags.contains(_filterTag)) {
        return false;
      }

      return true;
    }).toList();

    // แบ่ง Section: งานวันนี้ / งานอื่น ๆ
    final todayTasks =
        filtered.where((a) => _isSameDate(a.dueAt, now)).toList();
    final otherTasks =
        filtered.where((a) => !_isSameDate(a.dueAt, now)).toList();

    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ??
        (user?.email != null ? user!.email!.split('@').first : 'Taskly User');

    final todayLabel = DateFormat('EEE d MMM', 'th_TH').format(now);

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0D47A1),
        title: const Text(
          "Taskly",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            fontFamily: 'Prompt',
            color: Colors.white,
          ),
        ),
      ),
      drawer: _buildDrawer(context, user),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditAssignmentPage()),
          );
        },
        icon: const Icon(Icons.add, size: 26),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        label: const Text(
          "เพิ่มงาน",
          style: TextStyle(fontFamily: 'Prompt'),
        ),
      ),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- HEADER CARD (Hi Jackie) ----------------
                _buildHeaderCard(displayName, todayLabel),

                const SizedBox(height: 16),

                // ---------------- SEARCH + FILTERS ----------------
                _buildSearchAndFilters(context, items),

                const SizedBox(height: 12),

                // ---------------- SWITCH ONLY INCOMPLETE ----------------
                Transform.translate(
                  offset: const Offset(0, -4),
                  child: SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      "แสดงเฉพาะงานที่ยังไม่เสร็จ",
                      style: TextStyle(fontFamily: 'Prompt'),
                    ),
                    activeColor: const Color(0xFF0D47A1),
                    value: _showOnlyIncomplete,
                    onChanged: (v) => setState(() => _showOnlyIncomplete = v),
                  ),
                ),

                const SizedBox(height: 4),

                // ---------------- LIST SECTION ----------------
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: filtered.isEmpty
                            ? const Center(
                                child: Text(
                                  "ไม่พบงานที่ตรงกับเงื่อนไข",
                                  style: TextStyle(
                                    fontFamily: 'Prompt',
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : ListView(
                                children: [
                                  // TODAY TASKS
                                  _SectionHeader(
                                    title:
                                        "Today Tasks (${todayTasks.length})",
                                    accentColor: const Color(0xFF42A5F5),
                                  ),
                                  const SizedBox(height: 8),
                                  if (todayTasks.isEmpty)
                                    const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                        "ยังไม่มีงานวันนี้ 🎉",
                                        style: TextStyle(
                                          fontFamily: 'Prompt',
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  else
                                    ...todayTasks.map(
                                      (a) => _AssignmentCard(
                                        assignment: a,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                AddEditAssignmentPage(
                                              existing: a,
                                            ),
                                          ),
                                        ),
                                        onDelete: () =>
                                            _confirmDelete(context, a),
                                        onToggleDone: () => context
                                            .read<AssignmentProvider>()
                                            .toggleDone(a),
                                      ),
                                    ),

                                  const SizedBox(height: 16),

                                  // UPCOMING / OTHER TASKS
                                  _SectionHeader(
                                    title:
                                        "All Tasks (${otherTasks.length + todayTasks.length})",
                                    accentColor: const Color(0xFFAB47BC),
                                  ),
                                  const SizedBox(height: 8),
                                  ...otherTasks.map(
                                    (a) => _AssignmentCard(
                                      assignment: a,
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddEditAssignmentPage(
                                            existing: a,
                                          ),
                                        ),
                                      ),
                                      onDelete: () =>
                                          _confirmDelete(context, a),
                                      onToggleDone: () => context
                                          .read<AssignmentProvider>()
                                          .toggleDone(a),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------------
  // HEADER CARD
  // ------------------------------------------------------------------------
  Widget _buildHeaderCard(String name, String todayLabel) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF64B5F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.9), width: 2),
              color: Colors.blue, // สีพื้นหลังไอคอน
            ),
            child: const Icon(
              Icons.person,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hi, $name",
                  style: const TextStyle(
                    fontFamily: 'Prompt',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text(
                  "Here is your schedule and tasks today.",
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                todayLabel,
                style: const TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Today",
                  style: TextStyle(
                    fontFamily: 'Prompt',
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ------------------------------------------------------------------------
  // SEARCH + FILTER SECTION
  // ------------------------------------------------------------------------
  Widget _buildSearchAndFilters(BuildContext context, List<Assignment> items) {
    return Column(
      children: [
        // Search
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "ค้นหางาน...",
              hintStyle: TextStyle(fontFamily: 'Prompt'),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 10),

        // Category + Tag dropdown (compact)
        Row(
          children: [
            Expanded(
              child: _FilterChipLikeDropdown<String?>(
                label: "ประเภท",
                value: _filterCategory,
                displayText: _filterCategory ?? "ทั้งหมด",
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text("ทั้งหมด"),
                  ),
                  ...[
                    "งานเดี่ยว",
                    "งานกลุ่ม",
                    "รายงาน",
                    "งานเขียนโปรแกรม",
                    "งานสอบ",
                  ].map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _filterCategory = v),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FilterChipLikeDropdown<String?>(
                label: "Tag",
                value: _filterTag,
                displayText: _filterTag ?? "ทุก Tag",
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text("ทุก Tag"),
                  ),
                  ..._getAllTags(items).map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _filterTag = v),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ------------------------------------------------------------------------
  // Drawer
  // ------------------------------------------------------------------------
  Widget _buildDrawer(BuildContext context, User? user) {
  return Drawer(
    backgroundColor: const Color(0xFFE3F2FD),
    child: Column(
      children: [
        // ---------------- HEADER ----------------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 50, bottom: 30),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 48, color: Colors.blue[700]),
              ),
              const SizedBox(height: 12),
              Text(
                user?.email ?? "Guest User",
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Prompt',
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),

        // ---------------- MENU LIST ----------------
        _drawerTile(Icons.home_outlined, "หน้าแรก", () {
          Navigator.pop(context);
        }),

        _drawerTile(Icons.calendar_month, "ปฏิทิน", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CalendarPage()),
          );
        }),

        _drawerTile(Icons.settings, "การตั้งค่า", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          );
        }),

        const Spacer(),

        // ---------------- LOGOUT ----------------
        if (user != null)
          _drawerTile(Icons.logout, "ออกจากระบบ", () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }
          }, isLogout: true),

        const SizedBox(height: 20),
      ],
    ),
  );
}

// ========== WIDGET ปุ่มเมนูใน Drawer ==========
Widget _drawerTile(IconData icon, String text, VoidCallback onTap,
    {bool isLogout = false}) {
  return ListTile(
    leading: Icon(
      icon,
      color: isLogout ? Colors.red : const Color(0xFF0D47A1),
    ),
    title: Text(
      text,
      style: TextStyle(
        fontFamily: 'Prompt',
        color: isLogout ? Colors.red : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    ),
    onTap: onTap,
  );
}


  // ------------------------------------------------------------------------
  // ลบงาน
  // ------------------------------------------------------------------------
  Future<void> _confirmDelete(BuildContext context, Assignment a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'ยืนยัน',
          style: TextStyle(fontFamily: 'Prompt'),
        ),
        content: Text(
          'ต้องการลบงานวิชา "${a.subject}" ใช่หรือไม่?',
          style: const TextStyle(fontFamily: 'Prompt'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'ยกเลิก',
              style: TextStyle(fontFamily: 'Prompt'),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'ลบ',
              style: TextStyle(fontFamily: 'Prompt'),
            ),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      await context.read<AssignmentProvider>().remove(a.id);
    }
  }
}

// ------------------------------------------------------------------------
// Section Header Widget
// ------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color accentColor;

  const _SectionHeader({
    required this.title,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 18,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Prompt',
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

// ------------------------------------------------------------------------
// Filter dropdown styled like pill chip
// ------------------------------------------------------------------------
class _FilterChipLikeDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final String displayText;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _FilterChipLikeDropdown({
    required this.label,
    required this.value,
    required this.displayText,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          style: const TextStyle(
            fontFamily: 'Prompt',
            color: Colors.black87,
          ),
          hint: Text(
            label,
            style: const TextStyle(fontFamily: 'Prompt'),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------------
// CARD ของ Assignment (ดีไซน์ใหม่)
// ------------------------------------------------------------------------
class _AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onToggleDone;

  const _AssignmentCard({
    required this.assignment,
    required this.onTap,
    required this.onDelete,
    required this.onToggleDone,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (assignment.progress * 100).round();
    final dueTime = DateFormat('HH:mm').format(assignment.dueAt);
    final dueDateLabel = DateFormat('d MMM', 'th_TH').format(assignment.dueAt);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time + Menu Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // time indicator
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$dueTime  ·  $dueDateLabel",
                      style: const TextStyle(
                        fontFamily: 'Prompt',
                        fontSize: 11,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                assignment.subject,
                style: const TextStyle(
                  fontFamily: 'Prompt',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                assignment.category,
                style: TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),

              if (assignment.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: -6,
                  children: assignment.tags
                      .map(
                        (tag) => Chip(
                          label: Text(
                            tag,
                            style: const TextStyle(
                              fontFamily: 'Prompt',
                              fontSize: 11,
                            ),
                          ),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6.0),
                          backgroundColor: const Color(0xFFF3E5F5),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      )
                      .toList(),
                ),
              ],

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: assignment.progress,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        color: const Color(0xFF42A5F5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$progress%",
                    style: const TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  Checkbox(
                    value: assignment.isDone,
                    onChanged: (_) => onToggleDone(),
                    activeColor: const Color(0xFF0D47A1),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Text(
                    "เสร็จแล้ว",
                    style: TextStyle(
                      fontFamily: 'Prompt',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
