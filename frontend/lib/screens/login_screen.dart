import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = false;
  bool showPassword = false;

  void submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final response =
    await ApiService.login({'email': email.trim(), 'password': password});
    setState(() => isLoading = false);

    final message = response['message'] ?? 'Unknown error';
    final success = response['token'] != null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success && mounted) {
      final role = response['user']['role'];
      if (role == 'Parent') {
        Navigator.pushReplacementNamed(context, '/parentDashboard');
      } else if (role == 'Specialist') {
        Navigator.pushReplacementNamed(context, '/specialistDashboard');
      } else if (role == 'Admin') {
        Navigator.pushReplacementNamed(context, '/adminDashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
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
                      onPressed: () {},
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF8E88C7),
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                // Logo
                Image.asset(
                  'assets/images/jusoor_logo.png',
                  height: 100,
                ),
                SizedBox(height: 30),
                // Email
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Your Email',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.grey[800])),
                ),
                SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    hintText: 'contact@dscodetech.com',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      BorderSide(color: Colors.grey[300]!, width: 1.2),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (val) => email = val,
                  validator: (val) =>
                  val!.isEmpty ? 'Please enter your email' : null,
                ),
                SizedBox(height: 20),

                // Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Password',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.grey[800])),
                ),
                SizedBox(height: 8),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      BorderSide(color: Colors.grey[300]!, width: 1.2),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(showPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () =>
                          setState(() => showPassword = !showPassword),
                      color: Color(0xFF7815A0),

                    ),
                  ),
                  obscureText: !showPassword,
                  onChanged: (val) => password = val,
                  validator: (val) =>
                  val!.isEmpty ? 'Please enter your password' : null,
                ),
                SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(color: Color(0xFF7815A0)),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Continue Button
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
                        : Text('Continue',
                        style:
                        TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),

                SizedBox(height: 20),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(thickness: 1, color: Colors.grey)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('Or', style: TextStyle(color: Colors.grey[700])),
                    ),
                    Expanded(child: Divider(thickness: 1, color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 20),

                // Login with Apple
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Color(0xFF7815A0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(Icons.apple, color: Color(0xFF7815A0)),
                    label: Text('Login with Apple',
                        style: TextStyle(color: Color(0xFF7815A0))),
                    onPressed: () {},
                  ),
                ),
                SizedBox(height: 10),

                // Login with Google
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Color(0xFF7815A0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Image.asset('assets/images/jusoor_logo.png', height: 20),
                    label: Text('Login with Google',
                        style: TextStyle(color: Color(0xFF7815A0))),
                    onPressed: () {},
                  ),
                ),

                SizedBox(height: 25),

                // Signup link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ",
                        style: TextStyle(color: Colors.grey[800])),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                      child: Text('Sign up', style: TextStyle(color: Color(0xFF7815A0))),
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
