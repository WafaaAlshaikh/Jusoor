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
  String role = 'Parent'; // default

  bool isLoading = false;

  void submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() { isLoading = true; });
      final response = await ApiService.signup({
        'full_name': fullName,
        'email': email,
        'password': password,
        'role': role,
      });
      setState(() { isLoading = false; });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Signup')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Full Name'),
                onChanged: (val) => fullName = val,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (val) => email = val,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                onChanged: (val) => password = val,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              DropdownButtonFormField<String>(
                value: role,
                items: ['Parent','Admin','Specialist','Donor','Institution']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (val) => role = val!,
                decoration: InputDecoration(labelText: 'Role'),
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: submit,
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
