import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const LuxuryCarHubApp());
}

class LuxuryCarHubApp extends StatelessWidget {
  const LuxuryCarHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LuxuryCarHub',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
