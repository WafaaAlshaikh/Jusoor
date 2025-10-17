import 'package:flutter/material.dart';
import '../models/child_model.dart';
import 'sessions_tab.dart';
import '../models/session.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ChildTabs extends StatelessWidget {
  final Child child;
  const ChildTabs({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Profile'),
              Tab(text: 'Sessions'),
              Tab(text: 'Reports'),
              Tab(text: 'Payments'),
              Tab(text: 'Documents'),
              Tab(text: 'AI & Chat'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildProfileTab(),
                _buildSessionsTab(),
                _buildReportsTab(),
                _buildPaymentsTab(),
                _buildDocumentsTab(),
                _buildAiChatTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      ListTile(title: const Text('Full Name'), subtitle: Text(child.fullName)),
      ListTile(title: const Text('Date of Birth'), subtitle: Text(child.dateOfBirth ?? '-')),
      ListTile(title: const Text('Gender'), subtitle: Text(child.gender ?? '-')),
      ListTile(title: const Text('Condition'), subtitle: Text(child.condition ?? '-')),
      ListTile(title: const Text('Medical History'), subtitle: Text(child.medicalHistory ?? '-')),
    ],
  );

  Widget _buildSessionsTab() {
    return FutureBuilder<String>(
      future: _getToken(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final token = snapshot.data!;
        return SessionsTab(child: child, token: token);
      },
    );
  }

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }


  Widget _buildReportsTab() {
    final dummyReports = [
      {'title': 'Initial Assessment', 'date': '2025-09-01'},
      {'title': 'Monthly Progress', 'date': '2025-10-01'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: dummyReports.length,
      itemBuilder: (context, idx) {
        final r = dummyReports[idx];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.description),
            title: Text(r['title']!),
            subtitle: Text('Date: ${r['date']}'),
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    final dummyPayments = [
      {'desc': 'Session on 2025-09-13', 'amount': '20.00', 'status': 'Paid'},
      {'desc': 'Session on 2025-10-01', 'amount': '20.00', 'status': 'Due'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: dummyPayments.length,
      itemBuilder: (context, idx) {
        final p = dummyPayments[idx];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.payment),
            title: Text(p['desc']!),
            subtitle: Text('Amount: ${p['amount']} • ${p['status']}'),
          ),
        );
      },
    );
  }

  Widget _buildDocumentsTab() {
    final dummyFiles = [
      {'name': 'Diagnosis.pdf', 'date': '2025-09-01'},
      {'name': 'TherapyNotes.pdf', 'date': '2025-10-01'},
    ];
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: dummyFiles.length,
      itemBuilder: (context, idx) {
        final f = dummyFiles[idx];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: Text(f['name']!),
            subtitle: Text('Date: ${f['date']}'),
          ),
        );
      },
    );
  }

  Widget _buildAiChatTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.smart_toy),
          title: const Text('AI Daily Tip'),
          subtitle: Text(_generateAiTip()),
        ),
      ],
    );
  }

  String _generateAiTip() {
    final condition = (child.condition ?? '').toLowerCase();
    if (condition.contains('autism') || condition.contains('asd')) {
      return 'Use short visual schedules to help with transitions and reduce anxiety.';
    } else if (condition.contains('adhd')) {
      return 'Try short frequent tasks with immediate rewards to keep attention.';
    } else if (condition.contains('down')) {
      return 'Reinforce motor and language exercises with songs and repetition.';
    } else if (condition.contains('speech')) {
      return 'Practice daily short pronunciation exercises and encourage attempts.';
    } else {
      return 'Maintain a structured routine and track small wins weekly.';
    }
  }
}
