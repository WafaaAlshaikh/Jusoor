import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import '../widgets/parent_summary_card.dart';
import '../widgets/parent_action_button.dart';
import '../services/api_service.dart'; // تأكدي من وجود هذه الخدمة والدوال

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  int _selectedIndex = 0;

  Map<String, dynamic> dashboardData = {
    'parentName': 'Loading...',
    'parentPhone': '',
    'parentLocation': '',
    'parentImage': '',
    'upcomingSessions': 0,
    'newAIAdviceCount': 0,
    'recentNotifications': [],
  };

  List<Map<String, String>> enrolledChildren = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      if (token.isEmpty) return;

      final response = await ApiService.getParentDashboard(token);

      setState(() {
        dashboardData = {
          'parentName': response['parent']['name'],
          'parentPhone': response['parent']['phone'],
          'parentLocation': response['parent']['address'],
          'parentImage': response['parent']['image'] ?? '',
          'upcomingSessions': response['summaries']['upcomingSessions'],
          'newAIAdviceCount': response['summaries']['newAIAdviceCount'],
          'recentNotifications': List<Map<String, dynamic>>.from(
            response['summaries']['notifications'].map((n) => {
              'icon': Icons.notifications,
              'title': n['title'],
            }),
          ),
        };

        enrolledChildren = List<Map<String, String>>.from(
          response['children'].map((c) => {
            'name': c['name'],
            'condition': c['condition'],
            'image': c['image'] ?? '',
          }),
        );
      });
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
    }
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  // ---------------- Parent Avatar ----------------
  Widget _buildParentAvatar() {
    final image = dashboardData['parentImage'] ?? '';
    final name = dashboardData['parentName'] ?? '?';

    if (image.isNotEmpty) {
      return CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(image),
      );
    } else {
      return CircleAvatar(
        radius: 30,
        backgroundColor: ParentAppColors.primaryTeal.withOpacity(0.4),
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentAppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
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

  // ---------------- AppBar ----------------
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
            if (dashboardData['upcomingSessions'] > 0)
              const Positioned(
                right: 11,
                top: 11,
                child: Icon(Icons.circle, color: ParentAppColors.accentOrange, size: 8),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _buildParentAvatar(),
        ),
      ],
    );
  }

  // ---------------- Profile & Children ----------------
  Widget _buildParentProfileAndChildrenSummary() {
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
              _buildParentAvatar(),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back, ${dashboardData['parentName']}!',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: ParentAppColors.textDark),
                    ),
                    Text(
                      '${dashboardData['parentLocation']} | ${dashboardData['parentPhone']}',
                      style: const TextStyle(
                          color: ParentAppColors.textGrey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          Text(
            'Enrolled Children (${enrolledChildren.length})',
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
              itemCount: enrolledChildren.length,
              itemBuilder: (context, index) {
                final child = enrolledChildren[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: GestureDetector(
                    onTap: () {},
                    child: Column(
                      children: [
                        child['image']!.isEmpty
                            ? CircleAvatar(
                          radius: 25,
                          backgroundColor:
                          ParentAppColors.primaryTeal.withOpacity(0.4),
                          child: Text(
                            child['name']![0].toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        )
                            : CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(child['image']!),
                        ),
                        const SizedBox(height: 4),
                        Text(child['name']!,
                            style: const TextStyle(
                                fontSize: 12,
                                color: ParentAppColors.textDark)),
                        Text(child['condition']!,
                            style: const TextStyle(
                                fontSize: 10,
                                color: ParentAppColors.textGrey)),
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

  // ---------------- AI Tip Card ----------------
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

  // ---------------- Quick Summaries ----------------
  Widget _buildQuickSummaries() {
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
                count: dashboardData['upcomingSessions'],
                buttonText: 'View Calendar ➔',
                onTap: () {},
                color: ParentAppColors.primaryTeal,
              ),
              ParentSummaryCard(
                icon: Icons.auto_awesome,
                title: 'New AI Advice',
                count: dashboardData['newAIAdviceCount'],
                buttonText: 'See Archive ➔',
                onTap: () {},
                color: ParentAppColors.accentOrange,
              ),
              ParentSummaryCard(
                icon: Icons.people_alt_outlined,
                title: 'Children Enrolled',
                count: enrolledChildren.length,
                buttonText: 'Manage Children ➔',
                onTap: () {},
                color: ParentAppColors.primaryTeal,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- Main Actions Grid ----------------
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
                onTap: () {}),
            ParentActionButton(
                icon: Icons.forum_outlined,
                text: 'Community Forums',
                onTap: () {}),
          ],
        ),
      ],
    );
  }

  // ---------------- Notifications Feed ----------------
  Widget _buildRecentNotificationsFeed() {
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
        ...dashboardData['recentNotifications'].map<Widget>((activity) {
          return ListTile(
            leading: Icon(activity['icon'], color: ParentAppColors.primaryTeal),
            title: Text(activity['title'],
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

  // ---------------- Bottom Navigation ----------------
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
