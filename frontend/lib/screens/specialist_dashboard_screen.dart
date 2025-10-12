import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


// -------------------------------------------------------------------
// 1. Specialist Dashboard Screen
// -------------------------------------------------------------------
class AppColors {
  static const Color primaryPurple = Color(0xFFA3A1F7); // البنفسجي الفاتح
  static const Color darkPurple = Color(0xFF6A5ACD); // بنفسجي أغمق للـ CTA
  static const Color backgroundLight = Color(0xFFF9F9F9); // خلفية خفيفة
  static const Color textDark = Color(0xFF333333);
  static const Color textGrey = Color(0xFF888888);
}

class SpecialistDashboardScreen extends StatefulWidget {
  const SpecialistDashboardScreen({super.key});

  @override
  State<SpecialistDashboardScreen> createState() =>
      _SpecialistDashboardScreenState();
}

class _SpecialistDashboardScreenState extends State<SpecialistDashboardScreen> {
  int _selectedIndex = 0; // لـ Bottom Navigation Bar

  // بيانات وهمية للعرض
  final Map<String, dynamic> dashboardData = {
    'upcomingSessionsCount': 3,
    'childrenCount': 12,
    'unreadMessagesCount': 2,
    'latestInsight': 'Improvement of 20% in communication skills for Mohammed.',
    'recentActivities': [
      {'icon': Icons.check_circle, 'title': 'Session with Sarah completed.'},
      {'icon': Icons.history, 'title': 'Initial evaluation added for Ali.'},
      {'icon': Icons.campaign, 'title': 'Institution (Center X) launched a new campaign.'},
    ],
    'hasOnlineSessionNow': true, // حالة زر الـ CTA العائم
  };

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // هنا يمكن إضافة منطق التنقل بين الصفحات
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // الطبقة 2: بطاقات الملخص
            _buildSummaryCards(context),
            const SizedBox(height: 30),

            // الطبقة 4: شبكة الإجراءات السريعة
            _buildQuickActionsGrid(),
            const SizedBox(height: 30),

            // الطبقة 5: موجز النشاطات الأخيرة
            _buildRecentActivityFeed(),
          ],
        ),
      ),
      // الطبقة 3: زر الإجراء الرئيسي العائم (F-CTA)
      floatingActionButton: dashboardData['hasOnlineSessionNow'] == true
          ? _buildFloatingCTA()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // الطبقة 6: شريط التنقل السفلي الثابت
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // -------------------------------------------------------------------
  // A. الطبقة 1: شريط التنقل العلوي (AppBar)
  // -------------------------------------------------------------------
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false, // لا نريد زر العودة في الـ Dashboard
      title: const Text(
        'Specialist Dashboard',
        style: TextStyle(
          color: AppColors.textDark,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      actions: <Widget>[
        // أيقونة الإشعارات
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: AppColors.textDark),
              onPressed: () {
                // فتح قائمة الإشعارات
              },
            ),
            const Positioned(
              right: 11,
              top: 11,
              child: Icon(
                Icons.circle,
                color: AppColors.primaryPurple,
                size: 8,
              ),
            ),
          ],
        ),
        // صورة الملف الشخصي
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryPurple.withOpacity(0.2),
            backgroundImage: const NetworkImage('https://i.pravatar.cc/150?img=1'), // صورة وهمية
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------
  // B. الطبقة 2: بطاقات الملخص التفاعلية
  // -------------------------------------------------------------------
  Widget _buildSummaryCards(BuildContext context) {
    return SizedBox(
      height: 150, // تحديد ارتفاع ثابت للـ ScrollView الأفقي
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          _SummaryCard(
            icon: Icons.calendar_month,
            title: 'Upcoming Sessions',
            count: dashboardData['upcomingSessionsCount'],
            buttonText: 'View Next ➔',
            onTap: () {},
          ),
          _SummaryCard(
            icon: Icons.people,
            title: 'My Children',
            count: dashboardData['childrenCount'],
            buttonText: 'View List ➔',
            onTap: () {},
          ),
          _SummaryCard(
            icon: Icons.mail_outline,
            title: 'New Messages',
            count: dashboardData['unreadMessagesCount'],
            buttonText: 'Open Messages ➔',
            hasBadge: true,
            onTap: () {},
          ),
          _SummaryCard(
            icon: Icons.psychology_outlined,
            title: 'AI Insights',
            insightText: dashboardData['latestInsight'],
            buttonText: 'View Details ➔',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // C. الطبقة 4: شبكة الإجراءات السريعة
  // -------------------------------------------------------------------
  Widget _buildQuickActionsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark),
        ),
        const SizedBox(height: 15),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5, // لضبط نسبة العرض إلى الارتفاع للمربعات
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: <Widget>[
            _QuickActionButton(
                icon: Icons.add_circle_outline, text: 'Add Session', onTap: () {}),
            _QuickActionButton(
                icon: Icons.edit_note, text: 'New Evaluation', onTap: () {}),
            _QuickActionButton(
                icon: Icons.article_outlined, text: 'New Post/Article', onTap: () {}),
            _QuickActionButton(
                icon: Icons.beach_access, text: 'Vacation Request', onTap: () {}),
          ],
        ),
      ],
    );
  }

  // -------------------------------------------------------------------
  // D. الطبقة 5: موجز النشاطات الأخيرة
  // -------------------------------------------------------------------
  Widget _buildRecentActivityFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark),
        ),
        const SizedBox(height: 15),
        ...dashboardData['recentActivities'].map((activity) {
          return ListTile(
            leading: Icon(activity['icon'], color: AppColors.darkPurple),
            title: Text(activity['title'],
                style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Just now', style: TextStyle(color: AppColors.textGrey)),
            onTap: () {},
          );
        }).toList(),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text('View All Activity ➔', style: TextStyle(color: AppColors.primaryPurple)),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------
  // E. الطبقة 3: زر الإجراء الرئيسي العائم (F-CTA)
  // -------------------------------------------------------------------
  Widget _buildFloatingCTA() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SizedBox(
        width: double.infinity,
        child: FloatingActionButton.extended(
          onPressed: () {
            // منطق بدء الجلسة الأونلاين
          },
          label: const Text(
            'Start Online Session Now',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          icon: const Icon(Icons.video_call, color: Colors.white),
          backgroundColor: AppColors.darkPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // F. الطبقة 6: شريط التنقل السفلي الثابت
  // -------------------------------------------------------------------
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Sessions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'My Children',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.mail),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: AppColors.darkPurple,
      unselectedItemColor: AppColors.textGrey,
      showUnselectedLabels: true,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed, // يضمن بقاء جميع العناصر مرئية
    );
  }
}

// -------------------------------------------------------------------
// 2. Custom Widget: Summary Card
// -------------------------------------------------------------------
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int? count;
  final String? insightText;
  final String buttonText;
  final bool hasBadge;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.icon,
    required this.title,
    this.count,
    this.insightText,
    required this.buttonText,
    this.hasBadge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.primaryPurple, size: 28),
              if (hasBadge) // لعرض الدائرة الحمراء/البنفسجية في الرسائل
                const Icon(Icons.circle, color: Colors.red, size: 10),
            ],
          ),
          const SizedBox(height: 5),
          count != null
              ? Text(
            count.toString(),
            style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark),
          )
              : Text(
            insightText ?? '',
            style: const TextStyle(
                fontSize: 12, color: AppColors.textGrey),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onTap,
            child: Text(
              buttonText,
              style: const TextStyle(
                  color: AppColors.primaryPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
// 3. Custom Widget: Quick Action Button
// -------------------------------------------------------------------
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
            Icon(icon, color: AppColors.primaryPurple, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                  color: AppColors.textDark, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}