// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpcomingSessionsScreen extends StatefulWidget {
  final List<dynamic> upcomingSessions;
  final List<dynamic> completedSessions;

  const UpcomingSessionsScreen({
    super.key,
    required this.upcomingSessions,
    required this.completedSessions,
  });

  @override
  State<UpcomingSessionsScreen> createState() => _UpcomingSessionsScreenState();
}

class _UpcomingSessionsScreenState extends State<UpcomingSessionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String selectedChild = 'All';
  String? selectedType;
  String? selectedDateFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // ===============================================================
  // فلترة الجلسات
  // ===============================================================
  List<dynamic> filterSessions(List<dynamic> sessions, {bool onlyCompleted = false}) {
    return sessions.where((s) {
      bool matchesChild = selectedChild == 'All' || s['childName'] == selectedChild;
      bool matchesType = selectedType == null || s['sessionType'] == selectedType;
      bool matchesDate = true;

      if (selectedDateFilter == 'Today') {
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        matchesDate = s['date'] == today;
      } else if (selectedDateFilter == 'This Week') {
        final sessionDate = DateTime.tryParse(s['date'] ?? '') ?? DateTime.now();
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        matchesDate = sessionDate.isAfter(startOfWeek) && sessionDate.isBefore(endOfWeek);
      }

      bool matchesStatus = true;
      if (onlyCompleted) {
        matchesStatus = s['status'] == 'Completed';
      }

      return matchesChild && matchesType && matchesDate && matchesStatus;
    }).toList();
  }

  // ===============================================================
  // واجهة الصفحة
  // ===============================================================
  @override
  Widget build(BuildContext context) {
    final allChildren = {
      ...widget.upcomingSessions.map((s) => s['childName'] ?? 'Unknown'),
      ...widget.completedSessions.map((s) => s['childName'] ?? 'Unknown'),
    }.toList();

    final allTypes = {
      ...widget.upcomingSessions.map((s) => s['sessionType'] ?? 'Unknown'),
      ...widget.completedSessions.map((s) => s['sessionType'] ?? 'Unknown'),
    }.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Sessions'),
        backgroundColor: Colors.teal,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ===================== زر الفلاتر =====================
          _buildFilterButton(),
          const Divider(),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Upcoming
                _buildSessionList(
                    filterSessions(widget.upcomingSessions), true),
                // Completed
                _buildSessionList(
                    filterSessions(widget.completedSessions, onlyCompleted: true), false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // زر الفلاتر
  // ===============================================================
  Widget _buildFilterButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.filter_list),
        label: const Text('فلترة الجلسات'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => _buildFilterSheet(),
          );
        },
      ),
    );
  }

  // ===============================================================
  // BottomSheet للفلترة
  // ===============================================================
  Widget _buildFilterSheet() {
    final allChildren = {
      ...widget.upcomingSessions.map((s) => s['childName'] ?? 'Unknown'),
      ...widget.completedSessions.map((s) => s['childName'] ?? 'Unknown'),
    }.toList();

    final allTypes = {
      ...widget.upcomingSessions.map((s) => s['sessionType'] ?? 'Unknown'),
      ...widget.completedSessions.map((s) => s['sessionType'] ?? 'Unknown'),
    }.toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('اختر الطفل:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('الكل'),
                selected: selectedChild == 'All',
                onSelected: (_) => setState(() => selectedChild = 'All'),
              ),
              ...allChildren.map((c) => ChoiceChip(
                label: Text(c),
                selected: selectedChild == c,
                onSelected: (_) => setState(() => selectedChild = c),
              )),
            ],
          ),
          const SizedBox(height: 16),
          Text('اختر النوع:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('الكل'),
                selected: selectedType == null,
                onSelected: (_) => setState(() => selectedType = null),
              ),
              ...allTypes.map((t) => ChoiceChip(
                label: Text(t),
                selected: selectedType == t,
                onSelected: (_) => setState(() => selectedType = t),
              )),
            ],
          ),
          const SizedBox(height: 16),
          Text('اختر التاريخ:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('الكل'),
                selected: selectedDateFilter == null,
                onSelected: (_) => setState(() => selectedDateFilter = null),
              ),
              ChoiceChip(
                label: const Text('اليوم'),
                selected: selectedDateFilter == 'Today',
                onSelected: (_) => setState(() => selectedDateFilter = 'Today'),
              ),
              ChoiceChip(
                label: const Text('هذا الأسبوع'),
                selected: selectedDateFilter == 'This Week',
                onSelected: (_) => setState(() => selectedDateFilter = 'This Week'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('تطبيق الفلاتر'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // بناء قائمة الجلسات
  // ===============================================================
  Widget _buildSessionList(List<dynamic> sessions, bool isUpcoming) {
    if (sessions.isEmpty) {
      return const Center(
          child: Text('لا توجد جلسات مطابقة حالياً',
              style: TextStyle(fontSize: 16)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final s = sessions[index];
        return _buildSessionCard(s, isUpcoming);
      },
    );
  }

  // ===============================================================
  // بطاقة الجلسة
  // ===============================================================
  Widget _buildSessionCard(dynamic s, bool isUpcoming) {
    final dateTime = DateTime.tryParse('${s['date']} ${s['time']}') ?? DateTime.now();
    final diff = dateTime.difference(DateTime.now());
    final countdown = diff.isNegative
        ? 'بدأت'
        : 'تبدأ بعد ${diff.inHours} ساعة و ${diff.inMinutes % 60} دقيقة';

    Color statusColor = _getStatusColor(s['status']);

    double progress = isUpcoming
        ? (diff.inSeconds > 0
        ? 1 - (diff.inSeconds / Duration(days: 1).inSeconds).clamp(0.0, 1.0)
        : 1.0)
        : 1.0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: s['childPhoto'] != null && s['childPhoto'].isNotEmpty
                      ? NetworkImage(s['childPhoto'])
                      : null,
                  backgroundColor: Colors.teal[200],
                  child: s['childPhoto'] == null || s['childPhoto'].isEmpty
                      ? Text(
                    s['childName'] != null && s['childName'].isNotEmpty
                        ? s['childName'][0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['childName'] ?? 'غير معروف',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${s['specialistName'] ?? 'أخصائي غير محدد'} • ${s['institutionName'] ?? ''}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (isUpcoming)
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[200],
                          color: Colors.teal,
                          strokeWidth: 4,
                        ),
                        Center(
                          child: Icon(
                            Icons.access_time,
                            size: 20,
                            color: Colors.teal[700],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              DateFormat('EEE, d MMM yyyy • hh:mm a').format(dateTime),
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 5),
            Text(
              'النوع: ${s['sessionType'] ?? 'N/A'} | المدة: ${s['duration']} دقيقة | السعر: \$${s['price']}',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                s['status'] ?? '',
                style: TextStyle(
                    color: statusColor, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
            const SizedBox(height: 6),
            if (isUpcoming) Text('⏰ $countdown'),
            const SizedBox(height: 10),
            if (s['location'] != null && s['location'].isNotEmpty)
              GestureDetector(
                onTap: () async {
                  final uri = Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(s['location'])}');
                  if (await canLaunchUrl(uri)) launchUrl(uri);
                },
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.location_on, color: Colors.teal),
                      ),
                      Expanded(
                          child: Text(
                            s['location'],
                            style: TextStyle(color: Colors.teal[800]),
                          )),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.map, color: Colors.teal),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isUpcoming) ...[
                  TextButton.icon(
                    icon: Icon(Icons.check_circle_outline, color: Colors.teal),
                    label: Text('تأكيد'),
                    onPressed: () => _confirmSession(s['sessionId']),
                  ),
                  TextButton.icon(
                    icon: Icon(Icons.cancel_outlined, color: Colors.red),
                    label: Text('إلغاء'),
                    onPressed: () => _cancelSession(s['sessionId']),
                  ),
                ] else
                  TextButton.icon(
                    icon: Icon(Icons.description_outlined, color: Colors.teal),
                    label: Text('عرض التقرير'),
                    onPressed: () {},
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // وظائف الأزرار
  // ===============================================================
  void _confirmSession(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isEmpty) return;

    try {
      await ApiService.confirmSession(token, id);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('تم تأكيد الجلسة #$id ✅')));
      setState(() {
        final session = widget.upcomingSessions.firstWhere((s) => s['sessionId'] == id);
        session['status'] = 'Confirmed';
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    }
  }

  void _cancelSession(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isEmpty) return;

    try {
      await ApiService.cancelSession(token, id);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('تم إلغاء الجلسة #$id ❌')));
      setState(() {
        final session = widget.upcomingSessions.firstWhere((s) => s['sessionId'] == id);
        session['status'] = 'Cancelled';
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    }
  }

  // ===============================================================
  // ألوان الحالة
  // ===============================================================
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Scheduled':
        return Colors.blue;
      case 'Confirmed':
        return Colors.green;
      case 'Cancelled':
        return Colors.grey;
      case 'Completed':
        return Colors.teal;
      default:
        return Colors.orange;
    }
  }
}
