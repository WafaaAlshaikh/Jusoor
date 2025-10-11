import 'package:flutter/material.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  _ParentDashboardState createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, dynamic> parentProfile = {
    'name': 'Wafaa Al-Shaikh',
    'phone': '059-1234567',
    'address': 'Ramallah, Palestine',
    'children': [
      {'name': 'Ali', 'condition': 'ASD', 'age': 6},
      {'name': 'Sara', 'condition': 'ADHD', 'age': 8},
    ]
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        backgroundColor: const Color(0xFF6A11CB),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Profile'),
            Tab(icon: Icon(Icons.apartment), text: 'Institutions'),
            Tab(icon: Icon(Icons.people_alt), text: 'Community'),
            Tab(icon: Icon(Icons.settings), text: 'Settings'),
            Tab(icon: Icon(Icons.assignment), text: 'Assessment'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(),
          _buildInstitutionsTab(),
          _buildCommunityTab(),
          _buildSettingsTab(),
          _buildAssessmentTab(),
        ],
      ),
    );
  }

  // ---------------- Profile Tab ----------------
  Widget _buildProfileTab() {
    final List<dynamic> children = parentProfile['children'] as List<dynamic>;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Center(
            child: CircleAvatar(
              radius: 55,
              backgroundColor: Colors.purple.shade100,
              backgroundImage: const AssetImage('assets/profile.png'),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              parentProfile['name'] ?? '',
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF6A11CB)),
            ),
          ),
          const SizedBox(height: 5),
          Center(child: Text('📞 ${parentProfile['phone']}')),
          Center(child: Text('📍 ${parentProfile['address']}')),
          const Divider(height: 30),
          const Text('Children:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...children.map((child) {
            final Map<String, dynamic> c = child as Map<String, dynamic>;
            return _AnimatedChildCard(
              childData: c,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChildProfile(child: c)),
                );
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  // ---------------- Institutions Tab ----------------
  Widget _buildInstitutionsTab() {
    final List<Map<String, String>> institutions = [
      {'name': 'Yasmeen Charity', 'area': 'Ramallah', 'type': 'ASD'},
      {'name': 'Sanad Center', 'area': 'Nablus', 'type': 'Down Syndrome'},
      {'name': 'Hope Center', 'area': 'Hebron', 'type': 'Speech Disorders'},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by area or condition...',
              prefixIcon: const Icon(Icons.search),
              fillColor: Colors.purple.shade50,
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none),
            ),
            onChanged: (val) {
              setState(() {});
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: institutions.map((inst) {
                return _AnimatedInstitutionCard(
                  inst: inst,
                  onTap: () {},
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityTab() {
    return const Center(
      child: Text(
        'Community Chat & Support Groups',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return const Center(
      child: Text(
        'Settings - Update Profile, Password, Notifications',
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildAssessmentTab() {
    return const Center(
      child: Text(
        'Initial Diagnostic Assessment Form',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

// ---------------- Animated Child Card ----------------
class _AnimatedChildCard extends StatefulWidget {
  final Map<String, dynamic> childData;
  final VoidCallback onTap;
  const _AnimatedChildCard({required this.childData, required this.onTap});

  @override
  __AnimatedChildCardState createState() => __AnimatedChildCardState();
}

class __AnimatedChildCardState extends State<_AnimatedChildCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isPressed ? Colors.purple.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: _isPressed ? 2 : 5,
              offset: Offset(0, _isPressed ? 1 : 3),
            ),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.purple.shade100,
            child: Text(widget.childData['name'][0]),
          ),
          title: Text(widget.childData['name'],
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle:
          Text('${widget.childData['condition']} - ${widget.childData['age']} years'),
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }
}

// ---------------- Animated Institution Card ----------------
class _AnimatedInstitutionCard extends StatefulWidget {
  final Map<String, String> inst;
  final VoidCallback onTap;
  const _AnimatedInstitutionCard({required this.inst, required this.onTap});

  @override
  __AnimatedInstitutionCardState createState() =>
      __AnimatedInstitutionCardState();
}

class __AnimatedInstitutionCardState extends State<_AnimatedInstitutionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isPressed ? Colors.purple.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: _isPressed ? 2 : 5,
              offset: Offset(0, _isPressed ? 1 : 3),
            ),
          ],
        ),
        child: ListTile(
          title: Text(widget.inst['name'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle:
          Text('Area: ${widget.inst['area']} | Type: ${widget.inst['type']}'),
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }
}

// ---------------- Child Profile Page ----------------
class ChildProfile extends StatelessWidget {
  final Map<String, dynamic> child;
  const ChildProfile({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${child['name']}'s Profile"),
        backgroundColor: const Color(0xFF6A11CB),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.purple.shade50,
              child: Text(child['name'][0],
                  style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 10),
            Text('Name: ${child['name']}', style: const TextStyle(fontSize: 20)),
            Text('Condition: ${child['condition']}'),
            Text('Age: ${child['age']} years'),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Color(0xFF6A11CB)),
              title: const Text('Session Calendar'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Color(0xFF6A11CB)),
              title: const Text('Chat with Specialist'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.payment, color: Color(0xFF6A11CB)),
              title: const Text('Payments & Invoices'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: Color(0xFF6A11CB)),
              title: const Text('AI Recommendations'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
