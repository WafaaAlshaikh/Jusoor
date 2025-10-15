import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/child_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/auth'; // محاكي Android يستخدم localhost

  static Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }


  static Future<Map<String, dynamic>> sendResetCode(String email) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/password/send-reset-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> verifyResetCode(String email, String code) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/password/verify-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> resetPassword(
      String email, String code, String newPassword) async {
    final url = Uri.parse('http://10.0.2.2:5000/api/password/reset-password'); // الرابط الصحيح
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
        'newPassword': newPassword,
      }),
    );

    print('Reset password raw response: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        'success': false,
        'message': 'Server returned status code ${response.statusCode}'
      };
    }
  }


  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);
      if (data is Map<String, dynamic>) return data;
      return {'success': false, 'message': 'Server returned invalid response'};
    } catch (e) {
      print('JSON decode error: $e');
      return {'success': false, 'message': 'Server returned invalid response'};
    }
  }

  // ================= Parent Dashboard =================
  static Future<Map<String, dynamic>> getParentDashboard(String token) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/parent/dashboard'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load dashboard data: ${response.statusCode}');
    }
  }

  static Future<List<dynamic>> getUpcomingSessions(String token) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/parent/upcoming-sessions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return List<dynamic>.from(data['sessions'] ?? []);
    } else {
      throw Exception('Failed to load upcoming sessions: ${response.statusCode}');
    }
  }


  static Future<List<Child>> getChildren(String token) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/children'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((c) => Child.fromJson(c)).toList();
    } else {
      throw Exception('Failed to fetch children: ${response.statusCode}');
    }
  }

  static Future<Child> addChild(String token, Child child) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/children'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(child.toJson()),
    );
    if (response.statusCode == 201) {
      return Child.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add child: ${response.body}');
    }
  }

  static Future<Child> updateChild(String token, int id, Child child) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:5000/api/children/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(child.toJson()),
    );
    if (response.statusCode == 200) {
      return Child.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update child: ${response.body}');
    }
  }

  static Future<void> deleteChild(String token, int id) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:5000/api/children/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete child: ${response.body}');
    }
  }

}


