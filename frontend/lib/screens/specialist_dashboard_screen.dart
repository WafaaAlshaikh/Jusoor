import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/specialist_api.dart';
import '../theme/app_colors.dart';
import 'package:frontend/screens/specialist_sessions_screen.dart';
import 'package:frontend/screens/specialist_children_screen.dart';
import 'package:frontend/screens/add_evaluation_screen.dart';
import 'package:frontend/screens/full_vacation_request_screen.dart';
import 'package:frontend/screens/evaluations_screen.dart'; // أضف هذا
import 'package:frontend/screens/add_session_screen.dart'; // أضف هذا السطر
class SpecialistDashboardScreen extends StatefulWidget {
  const SpecialistDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SpecialistDashboardScreen> createState() =>
      _SpecialistDashboardScreenState();
}

class _SpecialistDashboardScreenState extends State<SpecialistDashboardScreen> {
  Map<String, dynamic> dashboardData = {};
  bool isLoading = true;

  // بيانات وهمية إضافية
  final List<Map<String, dynamic>> recentActivities = [
    {'icon': Icons.check_circle, 'title': 'Session with Sarah completed.'},
    {'icon': Icons.history, 'title': 'Initial evaluation added for Ali.'},
    {'icon': Icons.campaign, 'title': 'Institution (Center X) launched a new campaign.'},
  ];

  final int unreadMessagesCount = 2;
  bool hasOnlineSessionNow = true;

  @override
  void initState() {
    super.initState();
    fetchData();
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
      drawer: _buildDrawer(), // أضف الـ Drawer هنا
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
      floatingActionButton: hasOnlineSessionNow ? _buildFloatingCTA() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // دالة بناء الـ Drawer
  Widget _buildDrawer() {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.75, // عرض 75% من الشاشة
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header مع معلومات المستخدم
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

            // قائمة الـ Drawer Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.dashboard,
                    title: 'Dashboard',
                    onTap: () {
                      Navigator.pop(context); // إغلاق الـ Drawer
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.assessment,
                    title: 'Evaluations',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EvaluationsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.calendar_today,
                    title: 'Sessions',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpecialistSessionsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.people,
                    title: 'My Children',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpecialistChildrenScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.chat,
                    title: 'Messages',
                    badgeCount: unreadMessagesCount,
                    onTap: () {
                      // TODO: Navigate to Messages Screen
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.article,
                    title: 'Reports',
                    onTap: () {
                      // TODO: Navigate to Reports Screen
                      Navigator.pop(context);
                    },
                  ),

                  // Divider بين الأقسام
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Divider(height: 1),
                  ),

                  // قسم الإعدادات
                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      // TODO: Navigate to Settings Screen
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.help,
                    title: 'Help & Support',
                    onTap: () {
                      // TODO: Navigate to Help Screen
                      Navigator.pop(context);
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.info,
                    title: 'About',
                    onTap: () {
                      // TODO: Navigate to About Screen
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // زر Logout في الأسفل
            Container(
              padding: const EdgeInsets.all(20),
              child: _buildDrawerItem(
                icon: Icons.logout,
                title: 'Logout',
                color: Colors.red,
                onTap: () {
                  _showLogoutDialog();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة لبناء عنصر في الـ Drawer
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
    int? badgeCount,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? AppColors.primary,
        size: 22,

      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: color ?? AppColors.textDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: badgeCount != null && badgeCount > 0
          ? Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          badgeCount.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  // دالة لعرض dialog التأكيد عند Logout
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // إغلاق الـ Dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // TODO: تنفيذ عملية الـ Logout
                Navigator.pop(context); // إغلاق الـ Dialog
                Navigator.pop(context); // إغلاق الـ Drawer
                // إضافة منطق الـ Logout هنا
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // باقي الدوال كما هي بدون تغيير...
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
            Icons.menu,
            color: Colors.white, // أبيض
            size: 28,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Text(
        dashboardData['name'] ?? 'Specialist Dashboard',
        style: const TextStyle(
          color: AppColors.background,
          fontSize: 21,
        ),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.background),
              onPressed: () {},
            ),
            if (unreadMessagesCount > 0)
              const Positioned(
                right: 11,
                top: 11,
                child: Icon(
                  Icons.circle,
                  color: Colors.red,
                  size: 10,
                ),
              ),
          ],
        ),
        // أزل زر الـ Avatar من الـ AppBar لأنه موجود في الـ Drawer
      ],
    );
  }

  Widget _buildSummaryCards() {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: _SummaryCard(
              icon: Icons.calendar_month,
              title: 'Upcoming Sessions ',
              count: dashboardData['upcomingSessionsCount'] ?? 0,
              buttonText: 'View ➔',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SpecialistSessionsScreen(),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: _SummaryCard(
              icon: Icons.people,
              title: 'My Children',
              count: dashboardData['childrenCount'] ?? 0,
              buttonText: 'View ➔',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SpecialistChildrenScreen(),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: _SummaryCard(
              icon: Icons.mail_outline,
              title: 'New Messages',
              count: unreadMessagesCount,
              buttonText: 'Open Messages ➔',
              onTap: () {},
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: _SummaryCard(
              icon: Icons.psychology_outlined,
              title: 'AI Insights',
              count: 0,
              buttonText: 'View Details ➔',
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 20,
          runSpacing: 14,
          children: [
            _QuickActionButton(
              icon: Icons.add_circle_outline,
              text: 'Add Session',
              onTap: () {  Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddSessionScreen(),
                ),
              );
                },

            ),
            _QuickActionButton(
              icon: Icons.edit_note,
              text: 'New Evaluation',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEvaluationScreen(),
                  ),
                );
              },
            ),
            _QuickActionButton(
              icon: Icons.article_outlined,
              text: 'New Post/Article',
              onTap: () {},
            ),
            _QuickActionButton(
              icon: Icons.beach_access,
              text: 'Vacation Request',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VacationRequestScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivityFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          "Recent Activity",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
        ),
        const SizedBox(height: 12),
        ...recentActivities.map((activity) {
          return ListTile(
            leading: Icon(activity['icon'], color: AppColors.primary),
            title: Text(activity['title']),
            subtitle: const Text("Just now",
                style: TextStyle(color: AppColors.textGray)),
            onTap: () {},
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFloatingCTA() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: () {},
          label: const Text(
            'Start Online Session Now',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          icon: const Icon(Icons.video_call, color: Colors.white),
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
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
        // أزل More من الـ Bottom Navigation
      ],
      currentIndex: 0,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textGray,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        // إضافة التنقل بين الشاشات
        switch (index) {
          case 0:
          // Already on dashboard
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SpecialistSessionsScreen(),
              ),
            );
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SpecialistChildrenScreen(),
              ),
            );
            break;
          case 3:
          // TODO: Navigate to Messages
            break;
        }
      },
    );
  }
}

// باقي الـ Custom Widgets كما هي بدون تغيير...
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final String buttonText;
  final VoidCallback onTap;
  final String? insightText;

  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.buttonText,
    required this.onTap,
    this.insightText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 36),
            const SizedBox(height: 8),
            if (insightText == null)
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              )
            else
              Text(
                insightText!,
                style: const TextStyle(fontSize: 12, color: AppColors.textGray),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textGray,
              ),
            ),
            const SizedBox(height: 2),
            TextButton(onPressed: onTap, child: Text(buttonText)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 175,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}