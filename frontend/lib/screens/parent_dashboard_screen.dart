import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import '../widgets/parent_summary_card.dart';
import '../widgets/parent_action_button.dart';
import '../services/api_service.dart';
import '../models/parent.dart';
import '../models/child.dart';
import '../models/child_model.dart';
import '../models/notification_item.dart';
import '../models/summaries.dart';
import '../models/dashboard_data.dart';
import 'upcoming_sessions_screen.dart';
import 'manage_children_screen.dart';


// =================== DASHBOARD SCREEN ===================
class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  int _selectedIndex = 0;
  DashboardData? dashboardData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      if (token.isEmpty) {
        setState(() {
          _errorMessage = 'Token not found. Please login again.';
          _isLoading = false;
        });
        return;
      }

      final response = await ApiService.getParentDashboard(token);
      print('Dashboard API response: $response');

      if (response == null ||
          response['parent'] == null ||
          response['summaries'] == null) {
        setState(() {
          _errorMessage = 'Invalid data received from server.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        dashboardData = DashboardData.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
      setState(() {
        _errorMessage = 'Failed to load dashboard. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  // =================== AVATAR BUILDER ===================
  Widget _buildAvatar({required String name, required String image, double radius = 30}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: ParentAppColors.primaryTeal.withOpacity(0.4),
      child: image.isNotEmpty
          ? ClipOval(
        child: Image.network(
          image,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      )
          : Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentAppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchDashboardData,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParentProfileAndChildrenSummary(),
            const SizedBox(height: 30),
            _buildAITipCard(),
            const SizedBox(height: 30),
            _buildQuickSummaries(),
            const SizedBox(height: 30),
            _buildMainActionsGrid(),
            const SizedBox(height: 30),
            _buildRecentNotificationsFeed(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Parent Dashboard',
        style: TextStyle(
          color: ParentAppColors.textDark,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: ParentAppColors.textDark),
              onPressed: () {},
            ),
            if ((dashboardData?.summaries.upcomingSessions ?? 0) > 0)
              const Positioned(
                right: 11,
                top: 11,
                child: Icon(Icons.circle, color: ParentAppColors.accentOrange, size: 8),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _buildAvatar(
              name: dashboardData?.parent.name ?? '',
              image: dashboardData?.parent.profilePicture ?? ''),
        ),
      ],
    );
  }

  Widget _buildParentProfileAndChildrenSummary() {
    final children = dashboardData?.children ?? [];

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(
                  name: dashboardData?.parent.name ?? '',
                  image: dashboardData?.parent.profilePicture ?? ''),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back, ${dashboardData?.parent.name ?? '?'}!',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ParentAppColors.textDark),
                    ),
                    Text(
                      '${dashboardData?.parent.address ?? ''} | ${dashboardData?.parent.phone ?? ''}',
                      style: const TextStyle(color: ParentAppColors.textGrey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          Text(
            'Enrolled Children (${children.length})',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: ParentAppColors.textDark),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: children.length,
              itemBuilder: (context, index) {
                final child = children[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: GestureDetector(
                    onTap: () {},
                    child: Column(
                      children: [
                        _buildAvatar(
                            name: child.name,
                            image: child.image,
                            radius: 25),
                        const SizedBox(height: 4),
                        Text(
                          child.name,
                          style: const TextStyle(
                              fontSize: 12, color: ParentAppColors.textDark),
                        ),
                        Text(
                          child.condition,
                          style: const TextStyle(
                              fontSize: 10, color: ParentAppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAITipCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: ParentAppColors.accentOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: ParentAppColors.accentOrange, width: 1),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline,
              color: ParentAppColors.accentOrange, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily AI Tip for ASD:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ParentAppColors.textDark)),
                Text(
                  'Try using visual aids to ease transitions between daily activities, which can reduce anxiety.',
                  style: TextStyle(color: ParentAppColors.textDark),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSummaries() {
    final summaries = dashboardData?.summaries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Summary',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ParentAppColors.textDark),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ParentSummaryCard(
                icon: Icons.calendar_today,
                title: 'Upcoming Sessions',
                count: summaries?.upcomingSessions ?? 0,
                buttonText: 'View Calendar ➔',
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('token') ?? '';

                  if (token.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Token not found. Please login again.')),
                    );
                    return;
                  }

                  try {
                    final sessions = await ApiService.getUpcomingSessions(token);

                    if (sessions.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No upcoming sessions found')),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UpcomingSessionsScreen(
                          upcomingSessions: sessions, // هاي نفس الي كانت
                          completedSessions: const [], // مؤقتاً ما في داتا للجلسات المنتهية
                        ),

                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error fetching sessions: $e')),
                    );
                  }

                },
                color: ParentAppColors.primaryTeal,
              ),


              ParentSummaryCard(
                icon: Icons.auto_awesome,
                title: 'New AI Advice',
                count: summaries?.newAIAdviceCount ?? 0,
                buttonText: 'See Archive ➔',
                onTap: () {},
                color: ParentAppColors.accentOrange,
              ),
              ParentSummaryCard(
                icon: Icons.people_alt_outlined,
                title: 'Children Enrolled',
                count: dashboardData?.children.length ?? 0,
                buttonText: 'Manage Children ➔',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageChildrenScreen(),
                    ),
                  );
                },
                color: ParentAppColors.primaryTeal,
              ),

            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tools & Resources',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ParentAppColors.textDark),
        ),
        const SizedBox(height: 15),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            ParentActionButton(
                icon: Icons.assignment_outlined,
                text: 'Initial Screening',
                onTap: () {}),
            ParentActionButton(
                icon: Icons.local_hospital_outlined,
                text: 'Browse Centers',
                onTap: () {}),
            ParentActionButton(
              icon: Icons.child_care_outlined,
              text: 'Register New Child',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageChildrenScreen(),
                  ),
                );
              },
            ),

            ParentActionButton(
                icon: Icons.forum_outlined,
                text: 'Community Forums',
                onTap: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentNotificationsFeed() {
    final notifications = dashboardData?.summaries.notifications ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Latest Notifications',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ParentAppColors.textDark),
        ),
        const SizedBox(height: 15),
        ...notifications.map((activity) {
          return ListTile(
            leading: const Icon(Icons.notifications, color: ParentAppColors.primaryTeal),
            title: Text(activity.title,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('2 hours ago',
                style: TextStyle(color: ParentAppColors.textGrey)),
            trailing: const Icon(Icons.arrow_forward_ios,
                size: 16, color: ParentAppColors.textGrey),
            onTap: () {},
          );
        }).toList(),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'My Children'),
        BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: 'Centers'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Community'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: ParentAppColors.primaryTeal,
      unselectedItemColor: ParentAppColors.textGrey,
      showUnselectedLabels: true,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
    );
  }
}
