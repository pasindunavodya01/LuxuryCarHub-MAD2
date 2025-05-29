import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MapsScreen extends StatelessWidget {
  const MapsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps'),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.white,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
        ),
        child: const Center(
          child: Text(
            'Maps coming soon...',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
