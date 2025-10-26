// lib/screens/specialist_children_screen.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../services/specialist_children_service.dart';

class SpecialistChildrenScreen extends StatefulWidget {
  const SpecialistChildrenScreen({Key? key}) : super(key: key);

  @override
  State<SpecialistChildrenScreen> createState() => _SpecialistChildrenScreenState();
}

class _SpecialistChildrenScreenState extends State<SpecialistChildrenScreen> {
  List<dynamic> children = [];
  bool isLoading = true;
  String errorMessage = '';
  String _searchQuery = '';
  String _selectedFilter = 'all';
  List<String> _diagnosisTypes = ['all', 'ASD', 'ADHD', 'Down Syndrome', 'Speech & Language Disorder'];

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await SpecialistChildrenService.getSpecialistChildren();

      if (response['success'] == true) {
        setState(() {
          children = _safeList(response['data']?['children']);
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Failed to load children';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // تصفية الأطفال حسب البحث والفلتر
  List<dynamic> get _filteredChildren {
    return children.where((child) {
      final safeChild = _safeMap(child);
      final childName = _safeString(safeChild['full_name']).toLowerCase();
      final diagnosis = _safeMap(safeChild['diagnosis']);
      final diagnosisName = _safeString(diagnosis['name']).toLowerCase();

      // تطبيق البحث
      final matchesSearch = _searchQuery.isEmpty ||
          childName.contains(_searchQuery.toLowerCase()) ||
          diagnosisName.contains(_searchQuery.toLowerCase());

      // تطبيق الفلتر
      final matchesFilter = _selectedFilter == 'all' ||
          diagnosisName == _selectedFilter.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();
  }

  // دالة مساعدة للتعامل مع القوائم بشكل آمن
  List<dynamic> _safeList(dynamic list) {
    return list is List ? list : [];
  }

  // دالة مساعدة للتعامل مع الـ Map بشكل آمن
  Map<String, dynamic> _safeMap(dynamic map) {
    return map is Map<String, dynamic> ? map : {};
  }

  void _navigateToChildDetails(int childId, String childName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChildDetailsScreen(childId: childId, childName: childName),
      ),
    );
  }

  Widget _buildChildCard(dynamic child) {
    final safeChild = _safeMap(child);
    final childName = _safeString(safeChild['full_name']);
    final diagnosis = _safeMap(safeChild['diagnosis']);
    final evaluations = _safeList(safeChild['evaluations']);
    final totalSessions = _safeInt(safeChild['total_sessions']);
    final lastSession = _safeMap(safeChild['last_session']);
    final registrationStatus = _safeString(safeChild['registration_status']);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToChildDetails(_safeInt(safeChild['child_id']), childName),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with basic info
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Color(0xFF7815A0),
                    radius: 24,
                    child: Text(
                      childName.isNotEmpty ? childName[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          childName.isNotEmpty ? childName : 'Unknown',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            _buildStatusChip(registrationStatus),
                            SizedBox(width: 6),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color(0xFF7815A0).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                diagnosis['name'] ?? 'Not specified',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7815A0),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF7815A0)),
                ],
              ),

              SizedBox(height: 16),

              // Stats row
              _buildStatsRow(totalSessions, evaluations.length, lastSession),

              SizedBox(height: 12),

              // Quick progress indicator
              if (evaluations.isNotEmpty) _buildQuickProgress(evaluations),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        text = 'Approved';
        break;
      case 'pending':
        color = Colors.orange;
        text = 'Pending';
        break;
      default:
        color = Colors.grey;
        text = 'Not Registered';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatsRow(int sessions, int evaluations, Map<String, dynamic> lastSession) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(Icons.event, '$sessions', 'Sessions'),
        _buildStatItem(Icons.assessment, '$evaluations', 'Evaluations'),
        _buildStatItem(
            Icons.calendar_today,
            lastSession['date'] != null ? _formatDate(_safeString(lastSession['date'])) : 'N/A',
            'Last Session'
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Color(0xFF7815A0)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // ========== نظام التقييم المحسن والمتقدم ==========

  // تحليل التقدم للتقييمات - نسخة محسنة وذكية
  Map<String, dynamic> _analyzeProgress(List<dynamic> evaluations) {
    final safeEvaluations = _safeList(evaluations);

    if (safeEvaluations.isEmpty) {
      return {
        'trend': 'no_data',
        'message': 'No evaluations available',
        'improvement': 0.0,
        'hasEnoughData': false,
        'confidence': 'low',
        'trendColor': Colors.grey,
        'trendIcon': Icons.help_outline,
      };
    }

    if (safeEvaluations.length == 1) {
      final score = _safeDouble(safeEvaluations.first['progress_score']) ?? 0.0;
      return {
        'trend': 'initial',
        'message': 'Initial evaluation completed',
        'improvement': 0.0,
        'currentScore': score,
        'hasEnoughData': false,
        'confidence': 'medium',
        'trendColor': Colors.blue,
        'trendIcon': Icons.assessment,
        'firstScore': score,
        'lastScore': score,
      };
    }

    // ترتيب التقييمات من الأقدم إلى الأحدث
    final sortedEvaluations = List.from(safeEvaluations)
      ..sort((a, b) {
        try {
          final dateA = DateTime.parse(_safeString(a['created_at']));
          final dateB = DateTime.parse(_safeString(b['created_at']));
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });

    // تحليل متقدم
    final analysis = _advancedProgressAnalysis(sortedEvaluations);
    return analysis;
  }

  // تحليل متقدم للتقدم
  Map<String, dynamic> _advancedProgressAnalysis(List<dynamic> evaluations) {
    final scores = evaluations.map((e) => _safeDouble(e['progress_score']) ?? 0.0).toList();
    final dates = evaluations.map((e) => DateTime.parse(_safeString(e['created_at']))).toList();

    // 1. التحليل الأساسي (أول vs آخر)
    final firstScore = scores.first;
    final lastScore = scores.last;
    final simpleImprovement = lastScore - firstScore;

    // 2. متوسط التقدم
    final averageScore = scores.reduce((a, b) => a + b) / scores.length;

    // 3. تحليل الاتجاه (Linear Regression)
    final trendAnalysis = _calculateTrend(scores, dates);

    // 4. تحليل الاستقرار
    final stabilityAnalysis = _calculateStability(scores);

    // 5. تحليل التقدم الأخير
    final recentAnalysis = _analyzeRecentProgress(scores);

    // 6. تحديد التصنيف النهائي
    return _determineFinalClassification(
      simpleImprovement: simpleImprovement,
      trendSlope: trendAnalysis['slope'],
      stability: stabilityAnalysis['stability'],
      recentTrend: recentAnalysis['trend'],
      averageScore: averageScore,
      evaluationCount: scores.length,
      firstScore: firstScore,
      lastScore: lastScore,
    );
  }

  // حساب الاتجاه العام باستخدام Linear Regression
  Map<String, dynamic> _calculateTrend(List<double> scores, List<DateTime> dates) {
    if (scores.length < 2) {
      return {'slope': 0.0, 'rSquared': 0.0, 'trend': 'unknown'};
    }

    // تحويل التواريخ إلى أرقام (أيام من أول تاريخ)
    final firstDate = dates.first;
    final xValues = dates.map((date) => date.difference(firstDate).inDays.toDouble()).toList();

    // حساب Linear Regression
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    final n = scores.length.toDouble();

    for (int i = 0; i < scores.length; i++) {
      sumX += xValues[i];
      sumY += scores[i];
      sumXY += xValues[i] * scores[i];
      sumX2 += xValues[i] * xValues[i];
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    // حساب R-squared
    double ssTotal = 0, ssResidual = 0;
    final meanY = sumY / n;

    for (int i = 0; i < scores.length; i++) {
      final prediction = slope * xValues[i] + intercept;
      ssTotal += pow(scores[i] - meanY, 2);
      ssResidual += pow(scores[i] - prediction, 2);
    }

    final rSquared = ssTotal > 0 ? (1 - (ssResidual / ssTotal)) : 0.0;

    String trend;
    if (slope > 0.1) trend = 'strong_improvement';
    else if (slope > 0.02) trend = 'moderate_improvement';
    else if (slope > -0.02) trend = 'stable';
    else if (slope > -0.1) trend = 'moderate_decline';
    else trend = 'strong_decline';

    return {
      'slope': slope,
      'rSquared': rSquared,
      'trend': trend,
      'intercept': intercept,
    };
  }

  // حساب استقرار الأداء
  Map<String, dynamic> _calculateStability(List<double> scores) {
    if (scores.length < 2) {
      return {'stability': 'unknown', 'volatility': 0.0};
    }

    final average = scores.reduce((a, b) => a + b) / scores.length;
    final variance = scores.map((score) => pow(score - average, 2)).reduce((a, b) => a + b) / scores.length;
    final standardDeviation = sqrt(variance);
    final volatility = average > 0 ? (standardDeviation / average) * 100 : 0.0;

    String stability;
    if (volatility < 5) stability = 'very_stable';
    else if (volatility < 10) stability = 'stable';
    else if (volatility < 15) stability = 'moderate_volatility';
    else if (volatility < 20) stability = 'high_volatility';
    else stability = 'very_high_volatility';

    return {
      'stability': stability,
      'volatility': volatility,
      'standardDeviation': standardDeviation,
    };
  }

  // تحليل التقدم الأخير (آخر 3 تقييمات)
  Map<String, dynamic> _analyzeRecentProgress(List<double> scores) {
    if (scores.length < 3) {
      return {'trend': 'insufficient_data', 'recentImprovement': 0.0};
    }

    final recentScores = scores.sublist(scores.length - 3);
    final recentImprovement = recentScores.last - recentScores.first;

    String trend;
    if (recentImprovement > 5) trend = 'strong_recent_improvement';
    else if (recentImprovement > 2) trend = 'moderate_recent_improvement';
    else if (recentImprovement > -2) trend = 'stable_recent';
    else if (recentImprovement > -5) trend = 'moderate_recent_decline';
    else trend = 'strong_recent_decline';

    return {
      'trend': trend,
      'recentImprovement': recentImprovement,
      'recentScores': recentScores,
    };
  }

  // التصنيف النهائي الذكي
  Map<String, dynamic> _determineFinalClassification({
    required double simpleImprovement,
    required double trendSlope,
    required String stability,
    required String recentTrend,
    required double averageScore,
    required int evaluationCount,
    required double firstScore,
    required double lastScore,
  }) {
    // تقييم الثقة
    String confidence = 'medium';
    if (evaluationCount >= 5 && trendSlope.abs() > 0.05) confidence = 'high';
    if (evaluationCount < 3) confidence = 'low';

    // تحديد الاتجاه الأساسي
    String primaryTrend;
    Color trendColor;
    IconData trendIcon;
    String message;
    String detailedMessage;

    // تحليل متعدد العوامل
    final bool hasStrongImprovement = simpleImprovement > 15 || trendSlope > 0.15;
    final bool hasModerateImprovement = simpleImprovement > 5 || trendSlope > 0.05;
    final bool hasStablePerformance = simpleImprovement.abs() < 5 && trendSlope.abs() < 0.03;
    final bool hasModerateDecline = simpleImprovement < -5 || trendSlope < -0.05;
    final bool hasStrongDecline = simpleImprovement < -15 || trendSlope < -0.15;

    final bool isConsistent = stability == 'very_stable' || stability == 'stable';
    final bool hasRecentImprovement = recentTrend.contains('improvement');
    final bool hasRecentDecline = recentTrend.contains('decline');

    // التصنيف النهائي
    if (hasStrongImprovement && isConsistent) {
      primaryTrend = 'exceptional_improvement';
      trendColor = Colors.green[700]!;
      trendIcon = Icons.trending_up;
      message = 'Exceptional Progress! 🌟';
      detailedMessage = 'Outstanding consistent improvement with strong growth trajectory';
    }
    else if (hasStrongImprovement) {
      primaryTrend = 'significant_improvement';
      trendColor = Colors.green;
      trendIcon = Icons.trending_up;
      message = 'Excellent Progress! 🎉';
      detailedMessage = 'Significant improvement observed, though with some variability';
    }
    else if (hasModerateImprovement && hasRecentImprovement) {
      primaryTrend = 'accelerating_improvement';
      trendColor = Colors.green[400]!;
      trendIcon = Icons.trending_up;
      message = 'Steady Improvement 📈';
      detailedMessage = 'Consistent improvement with positive recent momentum';
    }
    else if (hasModerateImprovement) {
      primaryTrend = 'moderate_improvement';
      trendColor = Colors.lightGreen;
      trendIcon = Icons.trending_up;
      message = 'Good Progress 📈';
      detailedMessage = 'Steady improvement maintained over time';
    }
    else if (hasStablePerformance && isConsistent) {
      primaryTrend = 'very_stable';
      trendColor = Colors.blue;
      trendIcon = Icons.trending_flat;
      message = 'Very Stable Performance 🔄';
      detailedMessage = 'Highly consistent performance with minimal fluctuations';
    }
    else if (hasStablePerformance) {
      primaryTrend = 'stable';
      trendColor = Colors.orange;
      trendIcon = Icons.trending_flat;
      message = 'Stable Performance ➡️';
      detailedMessage = 'Overall stable performance with normal variations';
    }
    else if (hasModerateDecline && hasRecentDecline) {
      primaryTrend = 'accelerating_decline';
      trendColor = Colors.red[600]!;
      trendIcon = Icons.trending_down;
      message = 'Growing Concerns 📉';
      detailedMessage = 'Moderate decline with concerning recent trend';
    }
    else if (hasModerateDecline) {
      primaryTrend = 'moderate_decline';
      trendColor = Colors.orange[700]!;
      trendIcon = Icons.trending_down;
      message = 'Needs Attention 📉';
      detailedMessage = 'Moderate decline observed, requires intervention';
    }
    else if (hasStrongDecline) {
      primaryTrend = 'significant_decline';
      trendColor = Colors.red;
      trendIcon = Icons.trending_down;
      message = 'Significant Decline! ⚠️';
      detailedMessage = 'Major decline detected, immediate attention required';
    }
    else {
      primaryTrend = 'mixed_pattern';
      trendColor = Colors.purple;
      trendIcon = Icons.auto_graph;
      message = 'Mixed Pattern 🔄';
      detailedMessage = 'Complex performance pattern with varying trends';
    }

    // توصيات بناءً على التحليل
    final recommendations = _generateRecommendations(
      primaryTrend: primaryTrend,
      stability: stability,
      recentTrend: recentTrend,
      averageScore: averageScore,
      evaluationCount: evaluationCount,
    );

    return {
      'trend': primaryTrend,
      'message': message,
      'detailedMessage': detailedMessage,
      'improvement': simpleImprovement,
      'trendColor': trendColor,
      'trendIcon': trendIcon,
      'firstScore': firstScore,
      'lastScore': lastScore,
      'averageScore': averageScore,
      'evaluationCount': evaluationCount,
      'confidence': confidence,
      'stability': stability,
      'recentTrend': recentTrend,
      'trendSlope': trendSlope,
      'recommendations': recommendations,
      'hasEnoughData': true,
    };
  }

  // توليد توصيات ذكية
  List<String> _generateRecommendations({
    required String primaryTrend,
    required String stability,
    required String recentTrend,
    required double averageScore,
    required int evaluationCount,
  }) {
    final recommendations = <String>[];

    // توصيات بناءً على الاتجاه
    if (primaryTrend.contains('improvement')) {
      recommendations.add('Continue current intervention strategies');
      if (primaryTrend.contains('exceptional') || primaryTrend.contains('significant')) {
        recommendations.add('Consider advancing to more challenging goals');
      }
    }

    if (primaryTrend.contains('decline')) {
      recommendations.add('Review and adjust current intervention strategies');
      recommendations.add('Consider additional assessment to identify challenges');
      if (primaryTrend.contains('significant')) {
        recommendations.add('Urgent intervention recommended');
      }
    }

    if (primaryTrend.contains('stable')) {
      recommendations.add('Maintain consistent intervention approach');
      if (averageScore < 50) {
        recommendations.add('Consider intensifying support for breakthrough');
      }
    }

    // توصيات بناءً على الاستقرار
    if (stability.contains('high_volatility')) {
      recommendations.add('Focus on consistency and routine in sessions');
      recommendations.add('Monitor for external factors affecting performance');
    }

    if (stability.contains('very_stable')) {
      recommendations.add('Stable pattern allows for predictable progress planning');
    }

    // توصيات بناءً على التقدم الأخير
    if (recentTrend.contains('recent_improvement')) {
      recommendations.add('Recent positive trend - capitalize on current momentum');
    }

    if (recentTrend.contains('recent_decline')) {
      recommendations.add('Address recent challenges promptly');
    }

    // توصيات عامة
    if (evaluationCount < 4) {
      recommendations.add('More evaluations needed for comprehensive analysis');
    }

    if (averageScore < 40) {
      recommendations.add('Consider foundational skill development focus');
    } else if (averageScore > 80) {
      recommendations.add('Focus on advanced skill development and maintenance');
    }

    return recommendations;
  }

  Widget _buildQuickProgress(List<dynamic> evaluations) {
    final safeEvaluations = _safeList(evaluations);
    if (safeEvaluations.length < 2) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.info, size: 16, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Need more evaluations to show progress',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      );
    }

    final progressAnalysis = _analyzeProgress(evaluations);

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: progressAnalysis['trendColor'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: progressAnalysis['trendColor'].withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(progressAnalysis['trendIcon'], size: 16, color: progressAnalysis['trendColor']),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  progressAnalysis['message'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: progressAnalysis['trendColor'],
                  ),
                ),
                Text(
                  '${progressAnalysis['firstScore']?.toInt() ?? 0}% → ${progressAnalysis['lastScore']?.toInt() ?? 0}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${progressAnalysis['improvement'] > 0 ? '+' : ''}${progressAnalysis['improvement']?.toStringAsFixed(1) ?? '0.0'}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: progressAnalysis['trendColor'],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      if (date.isEmpty) return date;
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  // دوال مساعدة للتعامل مع البيانات بشكل آمن
  String _safeString(dynamic value) {
    return value?.toString() ?? '';
  }

  int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // بناء بطاقة تقييم محسنة مع معلومات كاملة
  Widget _buildEnhancedEvaluationCard(dynamic evaluation) {
    final safeEval = _safeMap(evaluation);
    final evalType = _safeString(safeEval['evaluation_type']);
    final progressScore = _safeDouble(safeEval['progress_score']);
    final notes = _safeString(safeEval['notes']);
    final createdAt = _safeString(safeEval['created_at']);
    final evaluator = _safeString(safeEval['evaluator_name']);
    final status = _safeString(safeEval['status']);
    final domains = _safeList(safeEval['assessment_domains']);

    // تحديد لون حسب النتيجة
    Color scoreColor = Colors.grey;
    if (progressScore >= 80) {
      scoreColor = Colors.green;
    } else if (progressScore >= 60) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header مع النوع والتاريخ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF7815A0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF7815A0)),
                  ),
                  child: Text(
                    evalType.isNotEmpty ? evalType : "General Evaluation",
                    style: TextStyle(
                      color: Color(0xFF7815A0),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${progressScore.toInt()}%',
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // معلومات التقييم
            _buildEvaluationInfoRow(Icons.calendar_today, 'Date', _formatDate(createdAt)),
            if (evaluator.isNotEmpty)
              _buildEvaluationInfoRow(Icons.person, 'Evaluator', evaluator),
            if (status.isNotEmpty)
              _buildEvaluationInfoRow(Icons.info, 'Status', status),

            // المجالات التقييمية
            if (domains.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                'Assessment Domains:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: domains.map<Widget>((domain) {
                  final domainMap = _safeMap(domain);
                  final domainName = _safeString(domainMap['name']);
                  final domainScore = _safeDouble(domainMap['score']);

                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      '$domainName: ${domainScore.toInt()}%',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  );
                }).toList(),
              ),
            ],

            // الملاحظات
            if (notes.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                'Notes:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  notes,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ),
            ],

            // التوصيات إذا كانت موجودة
            if (safeEval['recommendations'] != null) ...[
              SizedBox(height: 12),
              Text(
                'Recommendations:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.green[700],
                ),
              ),
              SizedBox(height: 4),
              ..._safeList(safeEval['recommendations']).map<Widget>((rec) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.arrow_right, size: 16, color: Colors.green),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _safeString(rec),
                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

// دالة مساعدة لعرض معلومات التقييم
  Widget _buildEvaluationInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredChildren = _filteredChildren;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'My Children',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFF7815A0),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadChildren,
          ),
        ],
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF7815A0)),
            SizedBox(height: 16),
            Text(
              'Loading children...',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage,
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadChildren,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7815A0),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Try Again', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Search and filter section only
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search children by name or diagnosis...',
                      prefixIcon: Icon(Icons.search, color: Color(0xFF7815A0)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 12),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _diagnosisTypes.map((diagnosis) {
                      final isSelected = _selectedFilter == diagnosis;
                      return Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            diagnosis == 'all' ? 'All Children' : diagnosis,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Color(0xFF7815A0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          backgroundColor: Colors.white,
                          selectedColor: Color(0xFF7815A0),
                          checkmarkColor: Colors.white,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = selected ? diagnosis : 'all';
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Color(0xFF7815A0)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Results count
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredChildren.length} children found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (filteredChildren.length != children.length)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedFilter = 'all';
                      });
                    },
                    child: Text(
                      'Clear filters',
                      style: TextStyle(color: Color(0xFF7815A0)),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8),

          // Children list
          Expanded(
            child: filteredChildren.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No children found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try adjusting your search or filters',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadChildren,
              color: Color(0xFF7815A0),
              child: ListView.builder(
                padding: EdgeInsets.only(bottom: 16),
                itemCount: filteredChildren.length,
                itemBuilder: (context, index) {
                  final child = filteredChildren[index];
                  return _buildChildCard(child);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChildDetailsScreen extends StatefulWidget {
  final int childId;
  final String childName;

  const ChildDetailsScreen({
    Key? key,
    required this.childId,
    required this.childName,
  }) : super(key: key);

  @override
  State<ChildDetailsScreen> createState() => _ChildDetailsScreenState();
}

class _ChildDetailsScreenState extends State<ChildDetailsScreen> {
  Map<String, dynamic>? childData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadChildDetails();
  }

  Future<void> _loadChildDetails() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await SpecialistChildrenService.getChildDetails(widget.childId);

      if (response['success'] == true) {
        setState(() {
          childData = response['data'];
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Failed to load child details';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // دوال مساعدة
  List<dynamic> _safeList(dynamic list) => list is List ? list : [];
  Map<String, dynamic> _safeMap(dynamic map) => map is Map<String, dynamic> ? map : {};
  String _safeString(dynamic value) => value?.toString() ?? '';
  int _safeInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  String _formatDate(String date) {
    try {
      if (date.isEmpty) return date;
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  // ========== نظام التقييم المحسن والمتقدم ==========

  // تحليل التقدم للتقييمات - نسخة محسنة وذكية
  Map<String, dynamic> _analyzeProgress(List<dynamic> evaluations) {
    final safeEvaluations = _safeList(evaluations);

    if (safeEvaluations.isEmpty) {
      return {
        'trend': 'no_data',
        'message': 'No evaluations available',
        'improvement': 0.0,
        'hasEnoughData': false,
        'confidence': 'low',
        'trendColor': Colors.grey,
        'trendIcon': Icons.help_outline,
      };
    }

    if (safeEvaluations.length == 1) {
      final score = _safeDouble(safeEvaluations.first['progress_score']) ?? 0.0;
      return {
        'trend': 'initial',
        'message': 'Initial evaluation completed',
        'improvement': 0.0,
        'currentScore': score,
        'hasEnoughData': false,
        'confidence': 'medium',
        'trendColor': Colors.blue,
        'trendIcon': Icons.assessment,
        'firstScore': score,
        'lastScore': score,
      };
    }

    // ترتيب التقييمات من الأقدم إلى الأحدث
    final sortedEvaluations = List.from(safeEvaluations)
      ..sort((a, b) {
        try {
          final dateA = DateTime.parse(_safeString(a['created_at']));
          final dateB = DateTime.parse(_safeString(b['created_at']));
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });

    // تحليل متقدم
    final analysis = _advancedProgressAnalysis(sortedEvaluations);
    return analysis;
  }

  // تحليل متقدم للتقدم
  Map<String, dynamic> _advancedProgressAnalysis(List<dynamic> evaluations) {
    final scores = evaluations.map((e) => _safeDouble(e['progress_score']) ?? 0.0).toList();
    final dates = evaluations.map((e) => DateTime.parse(_safeString(e['created_at']))).toList();

    // 1. التحليل الأساسي (أول vs آخر)
    final firstScore = scores.first;
    final lastScore = scores.last;
    final simpleImprovement = lastScore - firstScore;

    // 2. متوسط التقدم
    final averageScore = scores.reduce((a, b) => a + b) / scores.length;

    // 3. تحليل الاتجاه (Linear Regression)
    final trendAnalysis = _calculateTrend(scores, dates);

    // 4. تحليل الاستقرار
    final stabilityAnalysis = _calculateStability(scores);

    // 5. تحليل التقدم الأخير
    final recentAnalysis = _analyzeRecentProgress(scores);

    // 6. تحديد التصنيف النهائي
    return _determineFinalClassification(
      simpleImprovement: simpleImprovement,
      trendSlope: trendAnalysis['slope'],
      stability: stabilityAnalysis['stability'],
      recentTrend: recentAnalysis['trend'],
      averageScore: averageScore,
      evaluationCount: scores.length,
      firstScore: firstScore,
      lastScore: lastScore,
    );
  }

  // حساب الاتجاه العام باستخدام Linear Regression
  Map<String, dynamic> _calculateTrend(List<double> scores, List<DateTime> dates) {
    if (scores.length < 2) {
      return {'slope': 0.0, 'rSquared': 0.0, 'trend': 'unknown'};
    }

    // تحويل التواريخ إلى أرقام (أيام من أول تاريخ)
    final firstDate = dates.first;
    final xValues = dates.map((date) => date.difference(firstDate).inDays.toDouble()).toList();

    // حساب Linear Regression
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    final n = scores.length.toDouble();

    for (int i = 0; i < scores.length; i++) {
      sumX += xValues[i];
      sumY += scores[i];
      sumXY += xValues[i] * scores[i];
      sumX2 += xValues[i] * xValues[i];
    }

    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    final intercept = (sumY - slope * sumX) / n;

    // حساب R-squared
    double ssTotal = 0, ssResidual = 0;
    final meanY = sumY / n;

    for (int i = 0; i < scores.length; i++) {
      final prediction = slope * xValues[i] + intercept;
      ssTotal += pow(scores[i] - meanY, 2);
      ssResidual += pow(scores[i] - prediction, 2);
    }

    final rSquared = ssTotal > 0 ? (1 - (ssResidual / ssTotal)) : 0.0;

    String trend;
    if (slope > 0.1) trend = 'strong_improvement';
    else if (slope > 0.02) trend = 'moderate_improvement';
    else if (slope > -0.02) trend = 'stable';
    else if (slope > -0.1) trend = 'moderate_decline';
    else trend = 'strong_decline';

    return {
      'slope': slope,
      'rSquared': rSquared,
      'trend': trend,
      'intercept': intercept,
    };
  }

  // حساب استقرار الأداء
  Map<String, dynamic> _calculateStability(List<double> scores) {
    if (scores.length < 2) {
      return {'stability': 'unknown', 'volatility': 0.0};
    }

    final average = scores.reduce((a, b) => a + b) / scores.length;
    final variance = scores.map((score) => pow(score - average, 2)).reduce((a, b) => a + b) / scores.length;
    final standardDeviation = sqrt(variance);
    final volatility = average > 0 ? (standardDeviation / average) * 100 : 0.0;

    String stability;
    if (volatility < 5) stability = 'very_stable';
    else if (volatility < 10) stability = 'stable';
    else if (volatility < 15) stability = 'moderate_volatility';
    else if (volatility < 20) stability = 'high_volatility';
    else stability = 'very_high_volatility';

    return {
      'stability': stability,
      'volatility': volatility,
      'standardDeviation': standardDeviation,
    };
  }

  // تحليل التقدم الأخير (آخر 3 تقييمات)
  Map<String, dynamic> _analyzeRecentProgress(List<double> scores) {
    if (scores.length < 3) {
      return {'trend': 'insufficient_data', 'recentImprovement': 0.0};
    }

    final recentScores = scores.sublist(scores.length - 3);
    final recentImprovement = recentScores.last - recentScores.first;

    String trend;
    if (recentImprovement > 5) trend = 'strong_recent_improvement';
    else if (recentImprovement > 2) trend = 'moderate_recent_improvement';
    else if (recentImprovement > -2) trend = 'stable_recent';
    else if (recentImprovement > -5) trend = 'moderate_recent_decline';
    else trend = 'strong_recent_decline';

    return {
      'trend': trend,
      'recentImprovement': recentImprovement,
      'recentScores': recentScores,
    };
  }

  // التصنيف النهائي الذكي
  Map<String, dynamic> _determineFinalClassification({
    required double simpleImprovement,
    required double trendSlope,
    required String stability,
    required String recentTrend,
    required double averageScore,
    required int evaluationCount,
    required double firstScore,
    required double lastScore,
  }) {
    // تقييم الثقة
    String confidence = 'medium';
    if (evaluationCount >= 5 && trendSlope.abs() > 0.05) confidence = 'high';
    if (evaluationCount < 3) confidence = 'low';

    // تحديد الاتجاه الأساسي
    String primaryTrend;
    Color trendColor;
    IconData trendIcon;
    String message;
    String detailedMessage;

    // تحليل متعدد العوامل
    final bool hasStrongImprovement = simpleImprovement > 15 || trendSlope > 0.15;
    final bool hasModerateImprovement = simpleImprovement > 5 || trendSlope > 0.05;
    final bool hasStablePerformance = simpleImprovement.abs() < 5 && trendSlope.abs() < 0.03;
    final bool hasModerateDecline = simpleImprovement < -5 || trendSlope < -0.05;
    final bool hasStrongDecline = simpleImprovement < -15 || trendSlope < -0.15;

    final bool isConsistent = stability == 'very_stable' || stability == 'stable';
    final bool hasRecentImprovement = recentTrend.contains('improvement');
    final bool hasRecentDecline = recentTrend.contains('decline');

    // التصنيف النهائي
    if (hasStrongImprovement && isConsistent) {
      primaryTrend = 'exceptional_improvement';
      trendColor = Colors.green[700]!;
      trendIcon = Icons.trending_up;
      message = 'Exceptional Progress! 🌟';
      detailedMessage = 'Outstanding consistent improvement with strong growth trajectory';
    }
    else if (hasStrongImprovement) {
      primaryTrend = 'significant_improvement';
      trendColor = Colors.green;
      trendIcon = Icons.trending_up;
      message = 'Excellent Progress! 🎉';
      detailedMessage = 'Significant improvement observed, though with some variability';
    }
    else if (hasModerateImprovement && hasRecentImprovement) {
      primaryTrend = 'accelerating_improvement';
      trendColor = Colors.green[400]!;
      trendIcon = Icons.trending_up;
      message = 'Steady Improvement 📈';
      detailedMessage = 'Consistent improvement with positive recent momentum';
    }
    else if (hasModerateImprovement) {
      primaryTrend = 'moderate_improvement';
      trendColor = Colors.lightGreen;
      trendIcon = Icons.trending_up;
      message = 'Good Progress 📈';
      detailedMessage = 'Steady improvement maintained over time';
    }
    else if (hasStablePerformance && isConsistent) {
      primaryTrend = 'very_stable';
      trendColor = Colors.blue;
      trendIcon = Icons.trending_flat;
      message = 'Very Stable Performance 🔄';
      detailedMessage = 'Highly consistent performance with minimal fluctuations';
    }
    else if (hasStablePerformance) {
      primaryTrend = 'stable';
      trendColor = Colors.orange;
      trendIcon = Icons.trending_flat;
      message = 'Stable Performance ➡️';
      detailedMessage = 'Overall stable performance with normal variations';
    }
    else if (hasModerateDecline && hasRecentDecline) {
      primaryTrend = 'accelerating_decline';
      trendColor = Colors.red[600]!;
      trendIcon = Icons.trending_down;
      message = 'Growing Concerns 📉';
      detailedMessage = 'Moderate decline with concerning recent trend';
    }
    else if (hasModerateDecline) {
      primaryTrend = 'moderate_decline';
      trendColor = Colors.orange[700]!;
      trendIcon = Icons.trending_down;
      message = 'Needs Attention 📉';
      detailedMessage = 'Moderate decline observed, requires intervention';
    }
    else if (hasStrongDecline) {
      primaryTrend = 'significant_decline';
      trendColor = Colors.red;
      trendIcon = Icons.trending_down;
      message = 'Significant Decline! ⚠️';
      detailedMessage = 'Major decline detected, immediate attention required';
    }
    else {
      primaryTrend = 'mixed_pattern';
      trendColor = Colors.purple;
      trendIcon = Icons.auto_graph;
      message = 'Mixed Pattern 🔄';
      detailedMessage = 'Complex performance pattern with varying trends';
    }

    // توصيات بناءً على التحليل
    final recommendations = _generateRecommendations(
      primaryTrend: primaryTrend,
      stability: stability,
      recentTrend: recentTrend,
      averageScore: averageScore,
      evaluationCount: evaluationCount,
    );

    return {
      'trend': primaryTrend,
      'message': message,
      'detailedMessage': detailedMessage,
      'improvement': simpleImprovement,
      'trendColor': trendColor,
      'trendIcon': trendIcon,
      'firstScore': firstScore,
      'lastScore': lastScore,
      'averageScore': averageScore,
      'evaluationCount': evaluationCount,
      'confidence': confidence,
      'stability': stability,
      'recentTrend': recentTrend,
      'trendSlope': trendSlope,
      'recommendations': recommendations,
      'hasEnoughData': true,
    };
  }

  // توليد توصيات ذكية
  List<String> _generateRecommendations({
    required String primaryTrend,
    required String stability,
    required String recentTrend,
    required double averageScore,
    required int evaluationCount,
  }) {
    final recommendations = <String>[];

    // توصيات بناءً على الاتجاه
    if (primaryTrend.contains('improvement')) {
      recommendations.add('Continue current intervention strategies');
      if (primaryTrend.contains('exceptional') || primaryTrend.contains('significant')) {
        recommendations.add('Consider advancing to more challenging goals');
      }
    }

    if (primaryTrend.contains('decline')) {
      recommendations.add('Review and adjust current intervention strategies');
      recommendations.add('Consider additional assessment to identify challenges');
      if (primaryTrend.contains('significant')) {
        recommendations.add('Urgent intervention recommended');
      }
    }

    if (primaryTrend.contains('stable')) {
      recommendations.add('Maintain consistent intervention approach');
      if (averageScore < 50) {
        recommendations.add('Consider intensifying support for breakthrough');
      }
    }

    // توصيات بناءً على الاستقرار
    if (stability.contains('high_volatility')) {
      recommendations.add('Focus on consistency and routine in sessions');
      recommendations.add('Monitor for external factors affecting performance');
    }

    if (stability.contains('very_stable')) {
      recommendations.add('Stable pattern allows for predictable progress planning');
    }

    // توصيات بناءً على التقدم الأخير
    if (recentTrend.contains('recent_improvement')) {
      recommendations.add('Recent positive trend - capitalize on current momentum');
    }

    if (recentTrend.contains('recent_decline')) {
      recommendations.add('Address recent challenges promptly');
    }

    // توصيات عامة
    if (evaluationCount < 4) {
      recommendations.add('More evaluations needed for comprehensive analysis');
    }

    if (averageScore < 40) {
      recommendations.add('Consider foundational skill development focus');
    } else if (averageScore > 80) {
      recommendations.add('Focus on advanced skill development and maintenance');
    }

    return recommendations;
  }

  // ========== واجهات المستخدم المحسنة ==========

  // بناء رسم بياني متقدم مع تحليلات
  Widget _buildAdvancedProgressChart(List<dynamic> evaluations, Map<String, dynamic> analysis) {
    final safeEvaluations = _safeList(evaluations);

    if (safeEvaluations.isEmpty) {
      return _buildEmptyChart();
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // تحليل التقدم المحسن
          _buildEnhancedAnalysisCard(analysis),

          SizedBox(height: 16),

          // الرسم البياني
          _buildChartWithTrendLine(safeEvaluations, analysis),

          SizedBox(height: 16),

          // الإحصائيات المتقدمة
          _buildAdvancedStats(safeEvaluations, analysis),

          // التوصيات
          if (analysis['recommendations'] != null && analysis['recommendations'].isNotEmpty)
            _buildRecommendationsCard(analysis['recommendations']),
        ],
      ),
    );
  }

  // بطاقة تحليل محسنة
  Widget _buildEnhancedAnalysisCard(Map<String, dynamic> analysis) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: analysis['trendColor'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: analysis['trendColor'].withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(analysis['trendIcon'], color: analysis['trendColor'], size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  analysis['message'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: analysis['trendColor'],
                  ),
                ),
              ),
              _buildConfidenceBadge(analysis['confidence']),
            ],
          ),

          SizedBox(height: 8),

          Text(
            analysis['detailedMessage'] ?? '',
            style: TextStyle(
              fontSize: 12,
              color: analysis['trendColor'].withOpacity(0.8),
            ),
          ),

          if (analysis['hasEnoughData'] == true) ...[
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${analysis['firstScore']?.toInt() ?? 0}% → ${analysis['lastScore']?.toInt() ?? 0}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: analysis['trendColor'],
                  ),
                ),
                Text(
                  '${analysis['improvement'] > 0 ? '+' : ''}${analysis['improvement']?.toStringAsFixed(1) ?? '0.0'}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: analysis['trendColor'],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // بناء شارة الثقة
  Widget _buildConfidenceBadge(String confidence) {
    Color color;
    String text;
    IconData icon;

    switch (confidence) {
      case 'high':
        color = Colors.green;
        text = 'High Confidence';
        icon = Icons.verified;
        break;
      case 'medium':
        color = Colors.orange;
        text = 'Medium Confidence';
        icon = Icons.info_outline;
        break;
      case 'low':
        color = Colors.grey;
        text = 'Low Confidence';
        icon = Icons.warning_amber;
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
        icon = Icons.help_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // رسم بياني مع خط الاتجاه
  Widget _buildChartWithTrendLine(List<dynamic> evaluations, Map<String, dynamic> analysis) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress Overview',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[800]),
            ),
            Text(
              'All ${evaluations.length} evaluations',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        SizedBox(height: 16),
        Container(
          height: 140,
          child: evaluations.length > 7
              ? _buildScrollableChart(evaluations)
              : _buildStaticChart(evaluations),
        ),
        SizedBox(height: 8),
        Divider(),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildChartStat('First Score', '${_safeDouble(evaluations.first['progress_score'])?.toInt() ?? 0}%'),
            _buildChartStat('Last Score', '${_safeDouble(evaluations.last['progress_score'])?.toInt() ?? 0}%'),
            _buildChartStat('Evaluations', '${evaluations.length}'),
          ],
        ),
      ],
    );
  }

  // إحصائيات متقدمة
  Widget _buildAdvancedStats(List<dynamic> evaluations, Map<String, dynamic> analysis) {
    final scores = evaluations.map((e) => _safeDouble(e['progress_score']) ?? 0.0).toList();
    final average = scores.reduce((a, b) => a + b) / scores.length;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Average', '${average.toInt()}%', Icons.bar_chart), // تم التصحيح هنا
              _buildStatItem('Evaluations', '${evaluations.length}', Icons.assessment),
              _buildStatItem('Stability', _getStabilityText(analysis['stability']), Icons.balance),
            ],
          ),
          SizedBox(height: 8),
          if (analysis['trendSlope'] != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    'Trend Rate',
                    '${analysis['trendSlope'] > 0 ? '+' : ''}${(analysis['trendSlope'] * 100).toStringAsFixed(1)}%/day',
                    Icons.timeline
                ),
                _buildStatItem(
                    'Confidence',
                    analysis['confidence']?.toString().split('.').last ?? 'Medium',
                    Icons.psychology
                ),
              ],
            ),
        ],
      ),
    );
  }

  // بطاقة التوصيات
  Widget _buildRecommendationsCard(List<String> recommendations) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 16, color: Colors.blue),
              SizedBox(width: 6),
              Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // إضافة ConstrainedBox لمنع الارتفاع الزائد
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 150), // حد أقصى للارتفاع
            child: SingleChildScrollView( // إمكانية التمرير إذا كانت التوصيات طويلة
              child: Column(
                children: recommendations.map((recommendation) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.arrow_right, size: 16, color: Colors.blue),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          recommendation,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStabilityText(String stability) {
    switch (stability) {
      case 'very_stable': return 'Very Stable';
      case 'stable': return 'Stable';
      case 'moderate_volatility': return 'Moderate';
      case 'high_volatility': return 'Volatile';
      case 'very_high_volatility': return 'Very Volatile';
      default: return 'Unknown';
    }
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Color(0xFF7815A0)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.assessment, size: 40, color: Colors.grey[400]),
          SizedBox(height: 8),
          Text(
            'No evaluations yet',
            style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4),
          Text(
            'Start with initial evaluation to track progress',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ========== الوظائف الأساسية المحفوظة ==========

  // رسم بياني ثابت لعدد تقييمات قليل
  Widget _buildStaticChart(List<dynamic> evaluations) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: evaluations.asMap().entries.map((entry) {
        final index = entry.key;
        final evaluation = _safeMap(entry.value);
        final score = _safeDouble(evaluation['progress_score']) ?? 0.0;
        final height = (score / 100) * 80;
        final evalType = _safeString(evaluation['evaluation_type']);
        final date = _safeString(evaluation['created_at']);

        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                  message: '${evalType} Evaluation\n${_formatDate(date)}\nScore: ${score.toInt()}%',
                  child: Container(
                    width: 20,
                    height: height.clamp(10, 80).toDouble(), // حد أدنى 10 للارتفاع
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF7815A0), Color(0xFF9C27B0)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${score.toInt()}%',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    evalType.isNotEmpty ? evalType.substring(0, 1) : 'E',
                    style: TextStyle(fontSize: 8, color: Colors.grey[700], fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'E${index + 1}',
                  style: TextStyle(fontSize: 8, color: Colors.grey[500]),
                ),
                SizedBox(height: 2),
                Text(
                  _formatDate(date).split('/').sublist(0, 2).join('/'), // يوم/شهر فقط
                  style: TextStyle(fontSize: 7, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // رسم بياني قابل للتمرير لعدد تقييمات كبير
  Widget _buildScrollableChart(List<dynamic> evaluations) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: evaluations.asMap().entries.map((entry) {
          final index = entry.key;
          final evaluation = _safeMap(entry.value);
          final score = _safeDouble(evaluation['progress_score']) ?? 0.0;
          final height = (score / 100) * 80;
          final evalType = _safeString(evaluation['evaluation_type']);
          final date = _safeString(evaluation['created_at']);

          return Container(
            width: 30,
            margin: EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Tooltip(
                  message: '${evalType} Evaluation\n${_formatDate(date)}\nScore: ${score.toInt()}%',
                  child: Container(
                    width: 20,
                    height: height.clamp(10, 80).toDouble(),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF7815A0), Color(0xFF9C27B0)],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '${score.toInt()}%',
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
                SizedBox(height: 2),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    evalType.isNotEmpty ? evalType.substring(0, 1) : 'E',
                    style: TextStyle(fontSize: 7, color: Colors.grey[700], fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'E${index + 1}',
                  style: TextStyle(fontSize: 7, color: Colors.grey[500]),
                ),
                SizedBox(height: 1),
                Text(
                  _formatDate(date).split('/').sublist(0, 2).join('/'),
                  style: TextStyle(fontSize: 6, color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
// دالة مساعدة لعرض معلومات التقييم
  Widget _buildEvaluationInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

// دالة لعرض التفاصيل الكاملة للتقييم
  void _showEvaluationDetails(dynamic evaluation) {
    final safeEval = _safeMap(evaluation);
    final evalType = _safeString(safeEval['evaluation_type']);
    final progressScore = _safeDouble(safeEval['progress_score']);
    final notes = _safeString(safeEval['notes']);
    final createdAt = _safeString(safeEval['created_at']);
    final evaluator = _safeString(safeEval['evaluator_name'] ?? safeEval['specialist_name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$evalType Evaluation Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Date', _formatDate(createdAt)),
              if (evaluator.isNotEmpty) _buildDetailRow('Evaluator', evaluator),
              _buildDetailRow('Score', '${progressScore.toInt()}%'),
              if (notes.isNotEmpty) ...[
                SizedBox(height: 12),
                Text(
                  'Notes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(notes),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  // إحصائيات إضافية للرسم البياني
  Widget _buildChartStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7815A0),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF7815A0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Color(0xFF7815A0)),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
        subtitle: Text(value.isNotEmpty ? value : 'Not available', style: TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _buildEvaluationCard(dynamic evaluation) {
    final safeEval = _safeMap(evaluation);
    final evalType = _safeString(safeEval['evaluation_type']);
    final progressScore = _safeDouble(safeEval['progress_score']);
    final notes = _safeString(safeEval['notes']);
    final createdAt = _safeString(safeEval['created_at']);
    final evaluator = _safeString(safeEval['evaluator_name'] ?? safeEval['specialist_name']);
    final status = _safeString(safeEval['status'] ?? 'Completed');
    final domains = _safeList(safeEval['assessment_domains'] ?? safeEval['domains']);

    // تحديد لون حسب النتيجة
    Color scoreColor = Colors.grey;
    if (progressScore >= 75) {
      scoreColor = Colors.green;
    } else if (progressScore >= 45) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header مع النوع والتاريخ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF7815A0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF7815A0)),
                    ),
                    child: Text(
                      evalType.isNotEmpty ? evalType : "General Evaluation",
                      style: TextStyle(
                        color: Color(0xFF7815A0),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scoreColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${progressScore.toInt()}%',
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // معلومات التقييم
            _buildEvaluationInfoRow(Icons.calendar_today, 'Date', _formatDate(createdAt)),
            if (evaluator.isNotEmpty)
              _buildEvaluationInfoRow(Icons.person, 'Evaluator', evaluator),
            if (status.isNotEmpty && status != 'Completed')
              _buildEvaluationInfoRow(Icons.info, 'Status', status),

            // المجالات التقييمية
            if (domains.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                'Assessment Domains:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: domains.take(5).map<Widget>((domain) { // تحديد أقصى 5 مجالات
                  final domainMap = _safeMap(domain);
                  final domainName = _safeString(domainMap['name'] ?? domainMap['domain_name'] ?? domainMap['title']);
                  final domainScore = _safeDouble(domainMap['score'] ?? domainMap['progress_score']);

                  if (domainName.isEmpty) return SizedBox.shrink();

                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      domainScore > 0 ? '$domainName: ${domainScore.toInt()}%' : domainName,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  );
                }).toList(),
              ),
            ],

            // الملاحظات
            if (notes.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                'Notes:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  notes,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],

            // زر للمزيد من التفاصيل
            if (notes.isNotEmpty && notes.length > 100) ...[
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    _showEvaluationDetails(evaluation);
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  ),
                  child: Text(
                    'View Full Details',
                    style: TextStyle(
                      color: Color(0xFF7815A0),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(dynamic session) {
    final safeSession = _safeMap(session);
    final status = _safeString(safeSession['status']);
    final date = _safeString(safeSession['date']);
    final time = _safeString(safeSession['time']);
    final sessionType = _safeString(safeSession['session_type']);

    Color statusColor = Colors.grey;
    String statusText = status;

    switch (status) {
      case 'Completed':
        statusColor = Colors.green;
        statusText = 'Completed';
        break;
      case 'Cancelled':
        statusColor = Colors.red;
        statusText = 'Cancelled';
        break;
      case 'Scheduled':
        statusColor = Colors.orange;
        statusText = 'Scheduled';
        break;
      case 'Confirmed':
        statusColor = Colors.blue;
        statusText = 'Confirmed';
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF7815A0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.event, color: Color(0xFF7815A0)),
        ),
        title: Text('Session ${_formatDate(date)}', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Time: ${time.isNotEmpty ? time : "Not specified"} - Type: ${sessionType.isNotEmpty ? sessionType : "Not specified"}'),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            statusText,
            style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.childName.isNotEmpty ? widget.childName : 'Child Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF7815A0),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF7815A0)),
            SizedBox(height: 16),
            Text(
              'Loading child details...',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage,
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadChildDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7815A0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Try Again', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      )
          : childData == null
          ? Center(child: Text('No data available', style: TextStyle(fontSize: 16, color: Colors.grey[600])))
          : DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF7815A0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: TabBar(
                labelColor: Color(0xFF7815A0),
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                tabs: [
                  Tab(text: 'Information'),
                  Tab(text: 'Evaluations'),
                  Tab(text: 'Sessions'),
                ],
              ),
            ),
            Expanded(

              child: TabBarView(
                children: [
                  _buildInfoTab(),
                  _buildEvaluationsTab(),
                  _buildSessionsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab() {
    final child = _safeMap(childData?['child']);
    final parent = _safeMap(child['parent']);
    final diagnosis = _safeMap(child['diagnosis']);
    final institution = _safeMap(child['current_institution']);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard('Full Name', _safeString(child['full_name']), Icons.person),
          _buildInfoCard('Date of Birth', _formatDate(_safeString(child['date_of_birth'])), Icons.cake),
          _buildInfoCard('Gender', _safeString(child['gender']) == 'Male' ? 'Male' : 'Female', Icons.people),
          _buildInfoCard('Diagnosis', _safeString(diagnosis['name']), Icons.medical_services),
          _buildInfoCard('Institution', _safeString(institution['name']), Icons.school),
          _buildInfoCard('Parent', _safeString(parent['full_name']), Icons.family_restroom),
          _buildInfoCard('Email', _safeString(parent['email']), Icons.email),
          _buildInfoCard('Phone', _safeString(parent['phone']), Icons.phone),
          if (_safeString(child['medical_history']).isNotEmpty)
            _buildInfoCard('Medical History', _safeString(child['medical_history']), Icons.medical_information),
        ],
      ),
    );
  }

  Widget _buildEvaluationsTab() {
    final evaluations = _safeList(childData?['evaluations']);
    final progressAnalysis = _analyzeProgress(evaluations);

    return evaluations.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assessment, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No evaluations available',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    )
        : SingleChildScrollView(
      child: Column(
        children: [
          // Progress Chart at the top
          Padding(
            padding: EdgeInsets.all(16),
            child: _buildAdvancedProgressChart(evaluations, progressAnalysis),
          ),

          // Evaluations list - استخدام الدالة الموجودة
          ...evaluations.map((evaluation) =>
              _buildEvaluationCard(evaluation) // ← استخدام الدالة الأصلية
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildSessionsTab() {
    final sessions = _safeList(childData?['sessions']);

    return sessions.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No sessions available',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    )
        : ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        return _buildSessionCard(sessions[index]);
      },
    );
  }
}