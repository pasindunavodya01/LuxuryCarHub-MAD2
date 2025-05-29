import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const LuxuryCarHubApp());
}

class LuxuryCarHubApp extends StatefulWidget {
  const LuxuryCarHubApp({super.key});

  @override
  State<LuxuryCarHubApp> createState() => _LuxuryCarHubAppState();
}

class _LuxuryCarHubAppState extends State<LuxuryCarHubApp> {
  bool _initialized = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    setState(() {
      _isAuthenticated = token != null;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LuxuryCarHub',
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      home: _initialized
          ? (_isAuthenticated ? const MainScreen() : const LoginScreen())
          : const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
      routes: {
        '/main': (context) => const MainScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
