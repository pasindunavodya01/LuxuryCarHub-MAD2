import 'package:flutter/material.dart';
import 'dart:async';

class SuccessScreen extends StatefulWidget {
  final String message;
  final String? nextRoute;
  const SuccessScreen({Key? key, required this.message, this.nextRoute})
      : super(key: key);

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    Future.delayed(const Duration(seconds: 3), () {
      if (widget.nextRoute != null) {
        Navigator.of(context).pushReplacementNamed(widget.nextRoute!);
      } else {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.jpg',
              height: 120,
            ),
            const SizedBox(height: 24),
            const SizedBox(height: 8),
            AnimatedSlideText(message: 'Your trusted vehicle partner'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class AnimatedText extends StatefulWidget {
  final String message;
  const AnimatedText({Key? key, required this.message}) : super(key: key);

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _fade = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Text(
        widget.message,
        style: const TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class AnimatedSlideText extends StatefulWidget {
  final String message;
  const AnimatedSlideText({Key? key, required this.message}) : super(key: key);

  @override
  State<AnimatedSlideText> createState() => _AnimatedSlideTextState();
}

class _AnimatedSlideTextState extends State<AnimatedSlideText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _slide = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: Text(
        widget.message,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black54),
        textAlign: TextAlign.center,
      ),
    );
  }
}
