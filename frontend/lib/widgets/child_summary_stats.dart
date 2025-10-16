// lib/screens/manage_children/widgets/child_summary_stats.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class ChildSummaryStats extends StatefulWidget {
  final List<dynamic> childrenList;

  const ChildSummaryStats({super.key, required this.childrenList});

  @override
  State<ChildSummaryStats> createState() => _ChildSummaryStatsState();
}

class _ChildSummaryStatsState extends State<ChildSummaryStats> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final stats = await ApiService.getChildStatistics(token);
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        margin: EdgeInsets.all(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Children Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Total',
                  _stats['totalChildren']?.toString() ?? '0',
                  Icons.people,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Active',
                  _stats['activeChildren']?.toString() ?? '0',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  'Boys',
                  _stats['byGender']?['Male']?.toString() ?? '0',
                  Icons.face,
                  Colors.blueAccent,
                ),
                _buildStatCard(
                  'Girls',
                  _stats['byGender']?['Female']?.toString() ?? '0',
                  Icons.face_3,
                  Colors.pink,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}