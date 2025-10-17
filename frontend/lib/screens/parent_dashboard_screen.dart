// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import '../widgets/parent_summary_card.dart';
import '../widgets/parent_action_button.dart';
import '../services/api_service.dart';
import '../models/dashboard_data.dart';
import 'upcoming_sessions_screen.dart';
import 'manage_children_screen.dart';
import 'educational_resources_screen.dart';
import 'initial_screening_screen.dart';


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
      if (response == null) {
        setState(() {
          _errorMessage = 'Invalid data from server.';
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

  // ---------- Avatar ----------
  Widget _buildAvatar({required String name, required String image, double radius = 28}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: ParentAppColors.primaryTeal.withOpacity(0.3),
      child: (image.isNotEmpty)
          ? ClipOval(
        child: Image.network(
          image,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // هذا يظهر أول حرف إذا الصورة فشلت
            return Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: radius * 0.65,
                    fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      )
          : Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.65,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentAppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
          : RefreshIndicator(
        onRefresh: _fetchDashboardData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildParentProfileAndChildrenSummary(),
              SizedBox(height: 25),
              _buildAITipCard(),
              SizedBox(height: 25),
              _buildQuickSummaries(),
              SizedBox(height: 25),
              _buildProgressAndReports(),
              SizedBox(height: 25),
              _buildMainActionsGrid(),
              SizedBox(height: 25),
              _buildInstitutionSuggestions(),
              SizedBox(height: 25),
              _buildPaymentOverview(),
              SizedBox(height: 25),
              _buildCommunityHighlights(),
              SizedBox(height: 25),
              _buildRecentNotificationsFeed(),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ---------- App Bar ----------
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.2,
      title: Text('Parent Dashboard',
          style: TextStyle(
              color: ParentAppColors.textDark,
              fontSize: 21,
              fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: ParentAppColors.textDark),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _buildAvatar(
              name: dashboardData?.parent.name ?? '',
              image: dashboardData?.parent.profilePicture ?? ''),
        )
      ],
    );
  }

  // ---------- Parent + Children ----------
  Widget _buildParentProfileAndChildrenSummary() {
    final parent = dashboardData?.parent;
    final children = dashboardData?.children ?? [];

    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            _buildAvatar(name: parent?.name ?? '', image: parent?.profilePicture ?? ''),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back, ${parent?.name ?? ''} 👋',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  SizedBox(height: 4),
                  Text('${parent?.address ?? ''} • ${parent?.phone ?? ''}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            )
          ]),
          Divider(height: 25),
          Text('Your Children (${children.length})',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: children.length,
              separatorBuilder: (_, __) => SizedBox(width: 15),
              itemBuilder: (_, i) {
                final child = children[i];
                return Column(
                  children: [
                    _buildAvatar(name: child.name, image: child.image, radius: 25),
                    SizedBox(height: 5),
                    Text(child.name,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    Text(child.condition,
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------- AI Tip ----------
  Widget _buildAITipCard() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [ParentAppColors.accentOrange.withOpacity(0.8), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.deepOrangeAccent, size: 30),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Today’s AI Tip 🧠',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text(
                    'Encourage your child to make choices during playtime. It builds independence and communication skills.',
                    style: TextStyle(color: Colors.black87, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Quick Summaries ----------
  Widget _buildQuickSummaries() {
    final s = dashboardData?.summaries;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            ParentSummaryCard(
              icon: Icons.calendar_month,
              title: 'Upcoming Sessions',
              count: dashboardData?.summaries.upcomingSessions ?? 0,
              color: ParentAppColors.primaryTeal,
              buttonText: 'View All ➜',
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token') ?? '';
                final sessions = await ApiService.getUpcomingSessions(token);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => UpcomingSessionsScreen(
                            upcomingSessions: sessions, completedSessions: const [])));
              },
            ),
            ParentSummaryCard(
                icon: Icons.insights,
                title: 'New Reports',
                count: s?.newReportsCount ?? 0,
                color: Colors.deepPurpleAccent,
                buttonText: 'Open ➜',
                onTap: () {}),
            ParentSummaryCard(
                icon: Icons.child_care,
                title: 'Children',
                count: dashboardData?.children.length ?? 0,
                color: ParentAppColors.accentOrange,
                buttonText: 'Manage ➜',
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ManageChildrenScreen()));
                }),
          ]),
        )
      ],
    );
  }

  // ---------- Progress & Reports ----------
  Widget _buildProgressAndReports() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress & Reports',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          Text('Track your child’s improvement over time 📈',
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.65,
            color: ParentAppColors.primaryTeal,
            backgroundColor: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            minHeight: 10,
          ),
          SizedBox(height: 8),
          Align(
              alignment: Alignment.centerRight,
              child: Text('65% of therapy plan completed',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
        ],
      ),
    );
  }

  // ---------- Tools Grid ----------
  Widget _buildMainActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tools & Resources',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            ParentActionButton(
              icon: Icons.assignment,
              text: 'Initial Screening',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const InitialScreeningScreen()),
                );
              },
            ),
            ParentActionButton(icon: Icons.school, text: 'Browse Centers', onTap: () {}),
            ParentActionButton(
              icon: Icons.menu_book,
              text: 'Educational Resources',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EducationalResourcesScreen()),
                );
              },
            ),

            ParentActionButton(icon: Icons.forum, text: 'Community', onTap: () {}),
          ],
        ),
      ],
    );
  }

  // ---------- Institutions ----------
  Widget _buildInstitutionSuggestions() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 6)
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recommended Centers 🏥',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Column(
            children: [
              _buildInstitutionTile('Yasmeen Charity', 'Amman, Jordan', 'Autism, Speech Therapy'),
              _buildInstitutionTile('Sanad Center', 'Irbid', 'ADHD, Down Syndrome'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInstitutionTile(String name, String location, String tags) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading:
      CircleAvatar(radius: 25, backgroundColor: ParentAppColors.primaryTeal.withOpacity(0.2)),
      title: Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('$location • $tags', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }

  // ---------- Payment Overview ----------
  Widget _buildPaymentOverview() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 6)
      ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Payments 💳', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Next due: 25 Oct 2025', style: TextStyle(color: Colors.grey[700])),
          TextButton(onPressed: () {}, child: Text('Pay Now ➜'))
        ]),
        LinearProgressIndicator(
          value: 0.8,
          color: ParentAppColors.accentOrange,
          backgroundColor: Colors.grey[200],
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
        ),
        SizedBox(height: 6),
        Text('80% paid this month', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ]),
    );
  }

  // ---------- Community ----------
  Widget _buildCommunityHighlights() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: ParentAppColors.primaryTeal.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Community Highlights 🌟',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          _buildCommunityPost('New awareness event this Friday at Yasmeen Charity!'),
          _buildCommunityPost('Parents forum: Tips for managing ADHD routines.'),
        ],
      ),
    );
  }

  Widget _buildCommunityPost(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(children: [
      Icon(Icons.campaign, color: ParentAppColors.primaryTeal, size: 20),
      SizedBox(width: 8),
      Expanded(child: Text(text, style: TextStyle(fontSize: 13))),
    ]),
  );

  // ---------- Notifications ----------
  Widget _buildRecentNotificationsFeed() {
    final notifications = dashboardData?.summaries.notifications ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Latest Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        ...notifications.map((n) => ListTile(
          leading: Icon(Icons.notifications, color: ParentAppColors.primaryTeal),
          title: Text(n.title, style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('2 hours ago', style: TextStyle(color: Colors.grey[600])),
          trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          onTap: () {},
        )),
      ],
    );
  }

  // ---------- Bottom Navigation ----------
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.child_care), label: 'Children'),
        BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: 'Centers'),
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: ParentAppColors.primaryTeal,
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
    );
  }
}
