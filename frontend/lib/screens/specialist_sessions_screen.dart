import 'package:flutter/material.dart';

class SpecialistSessionsScreen extends StatelessWidget {
  const SpecialistSessionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Specialist Sessions'),
        backgroundColor: Color(0xFF7815A0),
      ),
      body: Center(
        child: Text(
          'This is the Specialist Sessions Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
