import 'package:flutter/material.dart';
import 'package:research_project/frontpage/frontpage.dart';
import 'package:research_project/onboarding/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AAPDARTHI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<bool>(
        future: _checkLogin(),
        builder: (context, snapshot) {
          // 🔹 Splash / loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 🔹 Error fallback
          if (snapshot.hasError) {
            return const Frontpage();
          }

          // 🔹 Normal flow
          final isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? const HomePage() : const Frontpage();
        },
      ),
    );
  }
}
