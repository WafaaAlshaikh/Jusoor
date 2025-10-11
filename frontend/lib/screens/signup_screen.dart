import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '';
  String email = '';
  String password = '';
  String role = 'Parent';
  String? phone;
  String? profilePicture;
  bool isLoading = false;
  bool showPassword = false;

  void submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final Map<String, dynamic> data = {
      'full_name': fullName.trim(),
      'email': email.trim(),
      'password': password,
      'role': role,
      'phone': phone,
      'profile_picture': profilePicture,
    };

    final response = await ApiService.signup(data);
    setState(() => isLoading = false);

    final message = response['message'] ?? 'Unknown error';
    final success = response['token'] != null || (response['success'] == true) || message.toLowerCase().contains('success');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success && mounted) {
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0E5FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              children: [


                // Tabs: Login / Signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF7815A0),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),

                // Logo
                Image.asset(
                  'assets/images/jusoor_logo.png',
                  height: 100,
                ),
                SizedBox(height: 30),

                // Full Name
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline, color: Color(0xFF7815A0)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => fullName = val,
                  validator: (val) => val!.trim().isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16),

                // Email
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF7815A0)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (val) => email = val,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 16),

                // Password
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF7815A0)),
                    suffixIcon: IconButton(
                      icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => showPassword = !showPassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  obscureText: !showPassword,
                  onChanged: (val) => password = val,
                  validator: (val) => val!.length < 6 ? 'Min 6 chars' : null,
                ),
                SizedBox(height: 16),

                // Phone
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Phone (Optional)',
                    prefixIcon: Icon(Icons.phone, color: Color(0xFF7815A0)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.phone,
                  onChanged: (val) => phone = val,
                ),
                SizedBox(height: 16),

                // Role Dropdown
                DropdownButtonFormField<String>(
                  value: role,
                  items: ['Parent','Admin','Specialist','Donor','Institution']
                      .map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (val) => role = val!,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.work_outline, color: Color(0xFF7815A0)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 24),

                // Signup Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Color(0xFF7815A0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isLoading ? null : submit,
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
                SizedBox(height: 20),

                // Link to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ", style: TextStyle(color: Colors.grey[800])),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text('Login', style: TextStyle(color: Color(0xFF7815A0))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
