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

  // ✅ جلب الأطفال التابعين لمؤسسة الأخصائي
  static Future<Map<String, dynamic>> getChildrenAndInstitution() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/specialist/children'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'children': List<Map<String, dynamic>>.from(responseData['children'] ?? []),
          'institution': Map<String, dynamic>.from(responseData['institution'] ?? {}),
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to load children',
          'children': [],
          'institution': {},
        };
      }
    } catch (error) {
      print('Error loading children: $error');
      return {
        'success': false,
        'message': 'Network error: $error',
        'children': [],
        'institution': {},
      };
    }
  }

  // ✅ إضافة جلسة جديدة
  static Future<Map<String, dynamic>> addSession({
    required int childId,
    required String date,
    required String time,
    required int duration,
    required double price,
    required String sessionType,
    int? institutionId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/sessions/add-session'),
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
}