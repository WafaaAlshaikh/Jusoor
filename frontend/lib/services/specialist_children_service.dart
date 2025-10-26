// lib/services/specialist_children_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SpecialistChildrenService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/specialist';

  // الحصول على التوكن من التخزين المحلي
  static Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      throw Exception('Failed to get token: $e');
    }
  }

  // جلب جميع الأطفال للاخصائي
  static Future<Map<String, dynamic>> getSpecialistChildren() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token found. Please login again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/children'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied. You are not authorized.');
      } else if (response.statusCode == 404) {
        throw Exception('Specialist not found.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch children. Status: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // جلب تفاصيل طفل محدد
  static Future<Map<String, dynamic>> getChildDetails(int childId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No token found. Please login again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/children/$childId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('You do not have access to this child\'s information.');
      } else if (response.statusCode == 404) {
        throw Exception('Child not found.');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch child details. Status: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}