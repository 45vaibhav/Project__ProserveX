import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'LoginPage.dart';
import 'UserDashboard.dart';
import 'AdminDashboard.dart';
import 'RegisterWorkerPage.dart';
import 'SignupPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProServeXApp());
}

class ProServeXApp extends StatelessWidget {
  const ProServeXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProServeX',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2980B9),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF6DD5FA),
        ),
        fontFamily: 'Roboto',
      ),

      // ✅ Remove "home:" when using named routes
      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const Signuppage(),
        '/userDashboard': (context) => const UserDashboard(),
        '/adminDashboard': (context) => const AdminDashboard(),
        '/registerWorker': (context) => const RegisterWorkerPage(),
        // optional splash route if you plan to add one later
        // '/splash': (context) => const SplashScreen(),
      },
    );
  }
}
