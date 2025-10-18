// main.dart
import 'package:flutter/material.dart';
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/parent_dashboard_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/splash_screen.dart'; // استيراد الشاشة الافتتاحية الجديدة
import 'screens/specialist_dashboard_screen.dart';
import 'screens/full_vacation_request_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jusoor App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(), // مسار الشاشة الافتتاحية
        '/signup': (context) => SignupScreen(),
        '/login': (context) => LoginScreen(),
        '/parentDashboard': (context) => ParentDashboardScreen(),
        // '/parentDashboard': (context) => ParentDashboard(),
        '/vacation': (context) => VacationRequestScreen(),
        '/forgotPassword': (context) => ForgotPasswordScreen(),
        '/specialistDashboard': (context) => SpecialistDashboardScreen(),
        '/resetPassword': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return ResetPasswordScreen(email: args['email'], code: args['code']);
        },
      },
    );
  }
}
