import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // ✅ دالة مساعدة لجلب التوكن
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ✅ جلب الأطفال التابعين لمؤسسة الأخصائي - معدل
  static Future<Map<String, dynamic>> getChildrenInInstitution() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/specialist/children'), // تأكد من المسار
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final children = json.decode(response.body);
        return {
          'success': true,
          'children': List<Map<String, dynamic>>.from(children),
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to load children',
          'children': [],
        };
      }
    } catch (error) {
      print('Error loading children: $error');
      return {
        'success': false,
        'message': 'Network error: $error',
        'children': [],
      };
    }
  }

  // ✅ إضافة جلسة جديدة - معدل (المسار تصحيح)
  static Future<Map<String, dynamic>> addSession({
    required int childId,
    required String date,
    required String time,
    int duration = 60,
    double price = 0,
    String sessionType = 'Onsite',
    int? institutionId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/specialist/sessions'), // المسار المعدل
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'child_id': childId,
          'institution_id': institutionId,
          'date': date,
          'time': time,
          'duration': duration,
          'price': price,
          'session_type': sessionType,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'],
          'session': responseData['session'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to create session',
        };
      }
    } catch (error) {
      print('Error creating session: $error');
      return {
        'success': false,
        'message': 'Network error: $error',
      };
    }
  }

  // ✅ جلب الجلسات القريبة (خلال 5-10 دقائق) - جديد
  static Future<Map<String, dynamic>> getImminentSessions() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/specialist/imminent-sessions'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'hasSessionsIn5Min': responseData['has_sessions_in_5_min'] ?? false,
          'hasSessionsIn10Min': responseData['has_sessions_in_10_min'] ?? false,
          'sessionsIn5Min': List<Map<String, dynamic>>.from(responseData['sessions_in_5_min'] ?? []),
          'sessionsIn10Min': List<Map<String, dynamic>>.from(responseData['sessions_in_10_min'] ?? []),
          'totalImminentSessions': responseData['total_imminent_sessions'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to load imminent sessions',
          'hasSessionsIn5Min': false,
          'hasSessionsIn10Min': false,
          'sessionsIn5Min': [],
          'sessionsIn10Min': [],
          'totalImminentSessions': 0,
        };
      }
    } catch (error) {
      print('Error loading imminent sessions: $error');
      return {
        'success': false,
        'message': 'Network error: $error',
        'hasSessionsIn5Min': false,
        'hasSessionsIn10Min': false,
        'sessionsIn5Min': [],
        'sessionsIn10Min': [],
        'totalImminentSessions': 0,
      };
    }
  }

  // ✅ جلب عدد الجلسات القادمة - جديد
  static Future<Map<String, dynamic>> getUpcomingSessionsCount() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/specialist/upcoming-sessions'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'upcomingSessions': responseData['upcoming_sessions'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to load upcoming sessions count',
          'upcomingSessions': 0,
        };
      }
    } catch (error) {
      print('Error loading upcoming sessions count: $error');
      return {
        'success': false,
        'message': 'Network error: $error',
        'upcomingSessions': 0,
      };
    }
  }

  // ✅ جلب عدد الأطفال - جديد
  static Future<Map<String, dynamic>> getChildrenCount() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/specialist/children-count'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'childrenCount': responseData['children_count'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to load children count',
          'childrenCount': 0,
        };
      }
    } catch (error) {
      print('Error loading children count: $error');
      return {
        'success': false,
        'message': 'Network error: $error',
        'childrenCount': 0,
      };
    }
  }
}