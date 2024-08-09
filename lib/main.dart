import 'package:firebase/admin/admin_dashboard.dart';
import 'package:firebase/admin/manage_user_profiles.dart';
import 'package:firebase/safety_officer/safety_officer_dashboard.dart';
import 'package:firebase/user/dashboard.dart';
import 'package:firebase/user/emergency_page.dart';
import 'package:firebase/user/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'user/login.dart';
import 'user/registration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: LoginPage(),
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
        '/dashboard': (context) => DashboardPage(),
        '/admin_dashboard': (context) => AdminDashboard(),
        '/safety_officer_dashboard': (context) => SafetyOfficerDashboard(),
        '/profile': (context) => ProfilePage(),
        '/emergency': (context) => EmergencyPage(),
        '/manage_user_profiles': (context) => ManageUserProfiles(),
      },
    );
  }
}
