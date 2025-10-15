import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SpecialistService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/specialist';

  // 🔸 Helper function to get token
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 🔹 1. جلب بيانات الملف الشخصي
  static Future<Map<String, dynamic>> getProfileInfo() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(response.body);
  }

  // 🔹 2. جلب عدد الجلسات القادمة
  static Future<int> getUpcomingSessionsCount() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/upcoming-sessions'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(response.body);
    return data['upcoming_sessions'] ?? 0;
  }

  // 🔹 3. جلب عدد الأطفال
  static Future<int> getChildrenCount() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/children-count'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final data = jsonDecode(response.body);
    return data['children_count'] ?? 0;
  }
}
