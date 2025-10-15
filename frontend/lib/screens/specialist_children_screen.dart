import 'package:flutter/material.dart';

class SpecialistChildrenScreen extends StatelessWidget {
  const SpecialistChildrenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Specialist Children'),
        backgroundColor: Color(0xFF7815A0),
      ),
      body: Center(
        child: Text(
          'This is the Specialist Children Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
