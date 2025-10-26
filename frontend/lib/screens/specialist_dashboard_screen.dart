import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/specialist_api.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import 'package:frontend/screens/specialist_sessions_screen.dart';
import 'package:frontend/screens/specialist_children_screen.dart';
import 'package:frontend/screens/add_evaluation_screen.dart';
import 'package:frontend/screens/full_vacation_request_screen.dart';
import 'package:frontend/screens/evaluations_screen.dart';
import 'package:frontend/screens/add_session_screen.dart';
import 'package:frontend/screens/community_screen.dart';
import 'package:frontend/screens/create_post_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/about_screen.dart';
import 'package:frontend/screens/help_support_screen.dart';
import 'package:frontend/screens/settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SpecialistDashboardScreen extends StatefulWidget {
  const SpecialistDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SpecialistDashboardScreen> createState() =>
      _SpecialistDashboardScreenState();
}

class _SpecialistDashboardScreenState extends State<SpecialistDashboardScreen> {
  Map<String, dynamic> dashboardData = {};
  bool isLoading = true;
  List<dynamic> imminentSessions = [];
  bool hasImminentSessions = false;
  Timer? _sessionCheckTimer;

  // بيانات وهمية إضافية
  final List<Map<String, dynamic>> recentActivities = [
    {'icon': Icons.check_circle, 'title': 'Session with Sarah completed.'},
    {'icon': Icons.history, 'title': 'Initial evaluation added for Ali.'},
    {'icon': Icons.campaign, 'title': 'Institution (Center X) launched a new campaign.'},
  ];

  final int unreadMessagesCount = 2;

  @override
  void initState() {
    super.initState();
    fetchData();
    _startAutoRefresh(); // بدء الـ auto-refresh خلف الكواليس
  }

  @override
  void dispose() {
    _sessionCheckTimer?.cancel(); // إلغاء الـ Timer عند إغلاق الشاشة
    super.dispose();
  }

  // دالة لبدء الـ auto-refresh خلف الكواليس
  void _startAutoRefresh() {
    // نتحقق أول مرة فوراً
    checkImminentSessions();

    // ثم نبدأ Timer يتكرر كل 30 ثانية (يمكنك تغيير المدة)
    _sessionCheckTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      checkImminentSessions();
    });
  }

  Future<void> fetchData() async {
    try {
      final profile = await SpecialistService.getProfileInfo();
      final upcomingCount = await SpecialistService.getUpcomingSessionsCount();
      final childrenCount = await SpecialistService.getChildrenCount();

      setState(() {
        dashboardData = {
          'name': profile['name'],
          'avatar': profile['avatar'],
          'upcomingSessionsCount': upcomingCount,
          'childrenCount': childrenCount,
        };
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error fetching dashboard data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> checkImminentSessions() async {
    try {
      final result = await SessionService.getImminentSessions();

      if (result['success'] == true) {
        final sessionsIn5Min = List<dynamic>.from(result['sessionsIn5Min'] ?? []);
        final sessionsIn10Min = List<dynamic>.from(result['sessionsIn10Min'] ?? []);

        final allSessions = [...sessionsIn5Min, ...sessionsIn10Min];

        final previousCount = imminentSessions.length;
        final newCount = allSessions.length;

        setState(() {
          imminentSessions = allSessions;
          hasImminentSessions = allSessions.isNotEmpty;
        });

        // طباعة للتتبع في الكونسول فقط (للتطوير)
        if (newCount != previousCount) {
          print('🔄 Sessions updated: $newCount (was: $previousCount)');
        }
      }
    } catch (e) {
      print('❌ Error checking imminent sessions: $e');
    }
  }

  void _showSessionDetails(Map<String, dynamic> session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSessionDetailsSheet(session),
    );
  }

  Widget _buildSessionDetailsSheet(Map<String, dynamic> session) {
    final bool isOnline = session['session_type'] == 'Online';
    final bool hasZoomMeeting = session['zoomMeeting'] != null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // العنوان
          Text(
            'Session Details',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),

          // معلومات الجلسة
          _buildSessionInfoItem(
            'Child',
            session['child']['full_name'] ?? 'Unknown',
            Icons.person,
          ),
          _buildSessionInfoItem(
            'Time',
            '${session['date']} at ${session['time'].substring(0, 5)}',
            Icons.access_time,
          ),
          _buildSessionInfoItem(
            'Type',
            session['session_type'],
            isOnline ? Icons.videocam : Icons.location_on,
          ),
          if (session['institution'] != null && session['institution']['name'] != null)
            _buildSessionInfoItem(
              'Institution',
              session['institution']['name'],
              Icons.business,
            ),

          const SizedBox(height: 20),

          // زر الإجراء حسب نوع الجلسة
          if (isOnline && hasZoomMeeting)
            _buildActionButton(
              'Join Zoom Meeting',
              Icons.video_call,
              AppColors.primary,
                  () {
                Navigator.pop(context);
                _launchZoomMeeting(session['zoomMeeting']['join_url']);
              },
            )
          else if (isOnline)
            _buildActionButton(
              'Create Zoom Meeting',
              Icons.add,
              AppColors.primary,
                  () {
                Navigator.pop(context);
              },
            )
          else
            _buildActionButton(
              'View Session Details',
              Icons.info,
              AppColors.primary,
                  () {
                Navigator.pop(context);
              },
            ),

          const SizedBox(height: 10),

          // زر إلغاء
          _buildActionButton(
            'Close',
            Icons.close,
            Colors.grey,
                () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfoItem(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGray,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchZoomMeeting(String joinUrl) async {
    try {
      if (await canLaunchUrl(Uri.parse(joinUrl))) {
        await launchUrl(
          Uri.parse(joinUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        _showZoomLinkDialog(joinUrl);
      }
    } catch (e) {
      _showZoomLinkDialog(joinUrl);
    }
  }

  void _showZoomLinkDialog(String joinUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Join Zoom Meeting'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Copy this link and open it in your browser:'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  joinUrl,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _copyToClipboard(joinUrl);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard')),
                );
              },
              child: const Text('Copy Link'),
            ),
          ],
        );
      },
    );
  }

  void _copyToClipboard(String text) async {
    print('📋 Link to copy: $text');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCards(),
            const SizedBox(height: 27),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildRecentActivityFeed(),
          ],
        ),
      ),
      floatingActionButton: hasImminentSessions ? _buildFloatingCTA() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
              color: AppColors.primary.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: dashboardData['avatar'] != null
                        ? NetworkImage(dashboardData['avatar'])
                        : null,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: dashboardData['avatar'] == null
                        ? Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.primary,
                    )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    dashboardData['name'] ?? 'Specialist',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Speech Therapist',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '4.8 (124 reviews)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textDark.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.assessment,
                    title: 'Evaluations',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EvaluationsScreen()));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.calendar_today,
                    title: 'Sessions',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SpecialistSessionsScreen()));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.people,
                    title: 'My Children',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SpecialistChildrenScreen()));
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.chat,
                    title: 'Messages',
                    badgeCount: unreadMessagesCount,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.article,
                    title: 'Community',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityScreen()));
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Divider(height: 1),
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen())),
                  ),
                  _buildDrawerItem(
                    icon: Icons.help,
                    title: 'Help & Support',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HelpSupportScreen())),
                  ),
                  _buildDrawerItem(
                    icon: Icons.info,
                    title: 'About',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AboutScreen())),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: _buildDrawerItem(
                icon: Icons.logout,
                title: 'Logout',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
    int? badgeCount,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary, size: 22),
      title: Text(title, style: TextStyle(fontSize: 16, color: color ?? AppColors.textDark, fontWeight: FontWeight.w500)),
      trailing: badgeCount != null && badgeCount > 0 ? Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
        child: Text(badgeCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ) : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: Builder(builder: (context) => IconButton(
        icon: Icon(Icons.menu, color: Colors.white, size: 28),
        onPressed: () => Scaffold.of(context).openDrawer(),
      )),
      title: Text(dashboardData['name'] ?? 'Specialist Dashboard', style: const TextStyle(color: AppColors.background, fontSize: 21)),
      actions: [
        Stack(children: [
          IconButton(icon: const Icon(Icons.notifications_none, color: AppColors.background), onPressed: () {}),
          if (unreadMessagesCount > 0) const Positioned(right: 11, top: 11, child: Icon(Icons.circle, color: Colors.red, size: 10)),
        ]),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.6, child: _SummaryCard(icon: Icons.calendar_month, title: 'Upcoming Sessions ', count: dashboardData['upcomingSessionsCount'] ?? 0, buttonText: 'View ➔', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SpecialistSessionsScreen())))),
          SizedBox(width: MediaQuery.of(context).size.width * 0.6, child: _SummaryCard(icon: Icons.people, title: 'My Children', count: dashboardData['childrenCount'] ?? 0, buttonText: 'View ➔', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SpecialistChildrenScreen())))),
          SizedBox(width: MediaQuery.of(context).size.width * 0.6, child: _SummaryCard(icon: Icons.mail_outline, title: 'New Messages', count: unreadMessagesCount, buttonText: 'Open Messages ➔', onTap: () {})),
          SizedBox(width: MediaQuery.of(context).size.width * 0.6, child: _SummaryCard(icon: Icons.psychology_outlined, title: 'AI Insights', count: 0, buttonText: 'View Details ➔', onTap: () {})),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Quick Actions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
      const SizedBox(height: 12),
      Wrap(spacing: 20, runSpacing: 14, children: [
        _QuickActionButton(icon: Icons.add_circle_outline, text: 'Add Session', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddSessionScreen()))),
        _QuickActionButton(icon: Icons.edit_note, text: 'New Evaluation', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddEvaluationScreen()))),
        _QuickActionButton(icon: Icons.article_outlined, text: 'New Post/Article', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostScreen()))),
        _QuickActionButton(icon: Icons.beach_access, text: 'Vacation Request', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VacationRequestScreen()))),
      ]),
    ]);
  }

  Widget _buildRecentActivityFeed() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 24),
      const Text("Recent Activity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
      const SizedBox(height: 12),
      ...recentActivities.map((activity) => ListTile(
        leading: Icon(activity['icon'], color: AppColors.primary),
        title: Text(activity['title']),
        subtitle: const Text("Just now", style: TextStyle(color: AppColors.textGray)),
        onTap: () {},
      )).toList(),
    ]);
  }

  Widget _buildFloatingCTA() {
    final firstSession = imminentSessions.isNotEmpty ? imminentSessions.first : null;
    final bool isOnline = firstSession != null && firstSession['session_type'] == 'Online';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: () => firstSession != null ? _showSessionDetails(firstSession) : null,
          label: Text(isOnline ? 'Start Online Session' : 'Upcoming Session', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          icon: Icon(isOnline ? Icons.video_call : Icons.access_time, color: Colors.white),
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Sessions'),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'My Children'),
        BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'Messages'),
      ],
      currentIndex: 0,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textGray,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        switch (index) {
          case 1: Navigator.push(context, MaterialPageRoute(builder: (context) => SpecialistSessionsScreen())); break;
          case 2: Navigator.push(context, MaterialPageRoute(builder: (context) => SpecialistChildrenScreen())); break;
        }
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final String buttonText;
  final VoidCallback onTap;
  final String? insightText;

  const _SummaryCard({required this.icon, required this.title, required this.count, required this.buttonText, required this.onTap, this.insightText});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(16.0), child: Column(children: [
        Icon(icon, color: AppColors.primary, size: 36),
        const SizedBox(height: 8),
        if (insightText == null) Text('$count', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark))
        else Text(insightText!, style: const TextStyle(fontSize: 12, color: AppColors.textGray), maxLines: 3, overflow: TextOverflow.ellipsis),
        Text(title, style: const TextStyle(fontSize: 16, color: AppColors.textGray)),
        const SizedBox(height: 2),
        TextButton(onPressed: onTap, child: Text(buttonText)),
      ])),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _QuickActionButton({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: onTap, child: Container(
      width: 175,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3)]),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w500)),
      ]),
    ));
  }
}