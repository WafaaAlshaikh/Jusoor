import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class UpcomingSessionsScreen extends StatefulWidget {
  final List<dynamic> upcomingSessions;
  final List<dynamic> completedSessions;

  const UpcomingSessionsScreen({
    super.key,
    required this.upcomingSessions,
    required this.completedSessions,
  });

  @override
  State<UpcomingSessionsScreen> createState() =>
      _UpcomingSessionsScreenState();
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

  List<dynamic> filterSessions(List<dynamic> sessions) {
    return sessions.where((s) {
      bool matchesChild = selectedChild == 'All' || s['childName'] == selectedChild;
      bool matchesType = selectedType == null || s['sessionType'] == selectedType;
      bool matchesDate = true;

      if (selectedDateFilter == 'Today') {
        matchesDate = s['date'] == DateFormat('yyyy-MM-dd').format(DateTime.now());
      } else if (selectedDateFilter == 'This Week') {
        final sessionDate = DateTime.parse(s['date']);
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        matchesDate = sessionDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
            sessionDate.isBefore(endOfWeek.add(const Duration(days: 1)));
      }

      return matchesChild && matchesType && matchesDate;
    }).toList();
  }

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
        title: const Text('Sessions Overview'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'عرض في التقويم',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ميزة عرض التقويم ستُضاف لاحقًا 🔜')),
              );
            },
          ),
        ],
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
          // ====== Filter ======
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedChild,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Child',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: 'All', child: Text('All')),
                      ...allChildren.map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedChild = value!);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Type',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...allTypes.map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedType = value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedDateFilter,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Date',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All')),
                      DropdownMenuItem(value: 'Today', child: Text('Today')),
                      DropdownMenuItem(value: 'This Week', child: Text('This Week')),
                    ],
                    onChanged: (value) {
                      setState(() => selectedDateFilter = value);
                    },
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSessionList(filterSessions(widget.upcomingSessions), true),
                _buildSessionList(filterSessions(widget.completedSessions), false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList(List<dynamic> sessions, bool isUpcoming) {
    if (sessions.isEmpty) {
      return const Center(child: Text('No sessions found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final s = sessions[index];

        // حساب العد التنازلي
        String countdown = '';
        if (isUpcoming) {
          final sessionDateTime = DateTime.tryParse('${s['date']} ${s['time']}') ?? DateTime.now();
          final diff = sessionDateTime.difference(DateTime.now());
          if (diff.isNegative) {
            countdown = 'Started';
          } else {
            final h = diff.inHours;
            final m = diff.inMinutes % 60;
            countdown = 'تبدأ بعد ${h}h ${m}m';
          }
        }

        return GestureDetector(
          onTap: () {
            // TODO: open session details page
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 15),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.teal[100],
                        child: Text(
                          s['childName'] != null && s['childName'].isNotEmpty
                              ? s['childName'][0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s['childName'] ?? 'Unknown',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${s['specialistName'] ?? 'Unknown'} | ${s['institutionName'] ?? ''}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Text(
                    '${s['date'] ?? ''} • ${s['time'] ?? ''} ${countdown.isNotEmpty ? '• $countdown' : ''}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 5),

                  Text(
                    'Type: ${s['sessionType'] ?? 'N/A'}  |  Duration: ${s['duration']} mins  |  Price: \$${s['price']}  |  Status: ${s['status']}',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 8),

                  // add center and map
                  if (s['location'] != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        Expanded(child: Text(s['location'])),
                        TextButton(
                          onPressed: () async {
                            final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(s['location'])}');
                            if (await canLaunchUrl(uri)) {
                              launchUrl(uri);
                            }
                          },
                          child: const Text('Open in Maps'),
                        )
                      ],
                    ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isUpcoming)
                        ...[
                          TextButton.icon(
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Confirm'),
                            onPressed: () => _confirmSession(s['sessionId']),
                          ),
                          const SizedBox(width: 5),
                          TextButton.icon(
                            icon: const Icon(Icons.cancel_outlined),
                            label: const Text('Cancel'),
                            onPressed: () => _cancelSession(s['sessionId']),
                          ),
                          const SizedBox(width: 5),
                          IconButton(
                            icon: const Icon(Icons.chat, color: Colors.teal),
                            tooltip: 'تواصل مع الأخصائي',
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('ميزة المحادثة قيد التطوير 💬')),
                              );
                            },
                          ),
                        ]
                      else
                        TextButton.icon(
                          icon: const Icon(Icons.description_outlined),
                          label: const Text('View Report'),
                          onPressed: () {
                            // TODO:session documentation
                          },
                        ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmSession(int id) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Confirmed session #$id')),
    );
    // TODO: API PATCH /confirm
  }

  void _cancelSession(int id) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cancelled session #$id')),
    );
    // TODO:  API PATCH /cancel
  }
}
