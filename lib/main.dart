import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'providers/favorite_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FavoriteProvider(),
      child: const LuxuryCarHubApp(),
    ),
  );
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
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.indigo,
        fontFamily: GoogleFonts.roboto().fontFamily,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.indigo,
        fontFamily: GoogleFonts.roboto().fontFamily,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900],
        cardColor: Colors.grey[800],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
      ),
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
