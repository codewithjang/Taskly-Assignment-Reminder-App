import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../providers/assignment_provider.dart';
import '../models/assignment.dart';
import 'add_edit_assignment_page.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focused = DateTime.now();
  DateTime? _selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AssignmentProvider>();

    // --------- map events ต่อวัน ----------
    final Map<DateTime, List<Assignment>> events = {};
    for (final a in ap.items) {
      final key = DateTime(a.dueAt.year, a.dueAt.month, a.dueAt.day);
      events.putIfAbsent(key, () => []).add(a);
    }

    List<Assignment> getEventsForDay(DateTime day) {
      final key = DateTime(day.year, day.month, day.day);
      final list = events[key] ?? [];
      list.sort((a, b) => a.dueAt.compareTo(b.dueAt));
      return list;
    }

    final selectedDay = _selected ?? DateTime.now();
    final scheduleForSelected = getEventsForDay(selectedDay);
    final monthLabel = DateFormat('MMMM yyyy').format(_focused);

    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF0D47A1),
        title: const Text(
          "ปฏิทิน",
          style: TextStyle(
            fontFamily: 'Prompt',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: [
                // ---------- Top Month Row ----------
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Schedule",
                          style: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          monthLabel,
                          style: const TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Colors.white60),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _focused = DateTime.now();
                          _selected = DateTime.now();
                        });
                      },
                      child: const Text(
                        "Today",
                        style: TextStyle(fontFamily: 'Prompt', fontSize: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ---------- Calendar Card ----------
                ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.98),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                      child: TableCalendar<Assignment>(
                        locale: 'th_TH',
                        focusedDay: _focused,
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2100, 12, 31),
                        calendarFormat: _format,
                        eventLoader: getEventsForDay,
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        selectedDayPredicate: (d) => isSameDay(_selected, d),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selected = selectedDay;
                            _focused = focusedDay;
                          });
                        },
                        onFormatChanged: (f) {
                          setState(() => _format = f);
                        },
                        calendarStyle: CalendarStyle(
                          outsideDaysVisible: false,
                          todayDecoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: const TextStyle(
                            fontFamily: 'Prompt',
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                          selectedDecoration: const BoxDecoration(
                            color: Color(0xFF42A5F5),
                            shape: BoxShape.circle,
                          ),
                          selectedTextStyle: const TextStyle(
                            fontFamily: 'Prompt',
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          defaultTextStyle: const TextStyle(
                            fontFamily: 'Prompt',
                          ),
                          weekendTextStyle: const TextStyle(
                            fontFamily: 'Prompt',
                          ),
                          markerDecoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          markersAlignment: Alignment.bottomCenter,
                          markersMaxCount: 3,
                          rowDecoration: const BoxDecoration(),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                          weekendStyle: TextStyle(
                            fontFamily: 'Prompt',
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: const TextStyle(
                            fontFamily: 'Prompt',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          leftChevronIcon: const Icon(Icons.chevron_left),
                          rightChevronIcon: const Icon(Icons.chevron_right),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ---------- Label: Schedule for date ----------
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _buildScheduleTitle(selectedDay, scheduleForSelected.length),
                    style: const TextStyle(
                      fontFamily: 'Prompt',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ---------- Schedule List ----------
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      color: Colors.white.withOpacity(0.95),
                      child: scheduleForSelected.isEmpty
                          ? const Center(
                              child: Text(
                                "ยังไม่มีงานในวันนี้",
                                style: TextStyle(
                                  fontFamily: 'Prompt',
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              itemCount: scheduleForSelected.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final a = scheduleForSelected[index];
                                return _ScheduleItemCard(assignment: a);
                              },
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

  String _buildScheduleTitle(DateTime date, int count) {
    final dateLabel = DateFormat('d MMM yyyy', 'th_TH').format(date);
    return "Schedule • $dateLabel  ($count)";
  }
}

// ----------------------------------------------------------------------
// SCHEDULE ITEM CARD (timeline style แบบในภาพขวา)
// ----------------------------------------------------------------------
class _ScheduleItemCard extends StatelessWidget {
  final Assignment assignment;

  const _ScheduleItemCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final timeLabel = DateFormat('HH:mm').format(assignment.dueAt);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline dot & line
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFFF7043),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 60,
              color: Colors.grey.shade300,
            ),
          ],
        ),
        const SizedBox(width: 10),
        // Time + card
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                timeLabel,
                style: const TextStyle(
                  fontFamily: 'Prompt',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddEditAssignmentPage(existing: assignment),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.subject,
                        style: const TextStyle(
                          fontFamily: 'Prompt',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        assignment.details,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Prompt',
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              assignment.category,
                              style: const TextStyle(
                                fontFamily: 'Prompt',
                                fontSize: 11,
                                color: Color(0xFF1565C0),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          if (assignment.tags.isNotEmpty)
                            Flexible(
                              child: Text(
                                assignment.tags.join(' · '),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Prompt',
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
