import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'OnboardingScreen.dart';
import 'LoginPage.dart';
import 'UserDashboard.dart';
import 'AdminDashboard.dart';
import 'RegisterWorkerPage.dart';
import 'SignupPage.dart';

// 🔹 Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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
      home: const SplashWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const Signuppage(),
        '/userDashboard': (context) => const UserDashboard(),
        '/adminDashboard': (context) => const AdminDashboard(),
        '/registerWorker': (context) => const RegisterWorkerPage(),
      },
    );
  }
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool? _hasSeenOnboarding;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
    _setupFCM();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Message received: ${message.notification?.title} - ${message.notification?.body}');
  // You can show a local in-app notification here
});
  }

  // 🔹 Check onboarding
  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('hasSeenOnboarding') ?? false;

    setState(() {
      _hasSeenOnboarding = seen;
    });
  }

  // 🔹 Setup FCM
  Future<void> _setupFCM() async {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('FCM Permission granted');
    }

    // Get token and save to Firestore
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? token = await messaging.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'fcmToken': token,
        });
      }
    }

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        final notification = message.notification!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${notification.title}: ${notification.body}"),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasSeenOnboarding == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasSeenOnboarding!) {
      return const OnboardingScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginPage();
        }

        final user = snapshot.data!;
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const LoginPage();
            }

            final data = userSnapshot.data!.data() as Map<String, dynamic>;
            final isAdmin = data['isAdmin'] ?? false;
            return isAdmin ? const AdminDashboard() : const UserDashboard();
          },
        );
      },
    );
  }
}
