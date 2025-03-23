import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();

    // Create animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Set up animation progress
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // First delay to show the content
    Timer(const Duration(milliseconds: 1500), () {
      setState(() {
        _showContent = true;
      });
      // Start color transition once content is visible
      _controller.forward();
    });

    // Navigate to wrapper after animation completes
    // Changed from '/login' to '/wrapper'
    Timer(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, '/wrapper');
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
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFFCF0F7)),
        child: Center(
          child: AnimatedOpacity(
            opacity: _showContent ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Heart logo with gradient effect
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [
                            Color.lerp(
                              Colors.white,
                              const Color(0xFFEE82A5),
                              _animation.value,
                            )!, // Pink
                            Color.lerp(
                              Colors.white,
                              const Color(0xFF9EBBF0),
                              _animation.value,
                            )!, // Light blue
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds);
                      },
                      child: const Image(
                        image: AssetImage('assets/logo.png'),
                        height: 80,
                        color: Colors.white, // This color serves as the mask
                      ),
                    ),
                    const SizedBox(height: 16),
                    // AuraBloom text with gradient effect
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: [
                            Color.lerp(
                              Colors.white,
                              const Color(0xFFEE82A5),
                              _animation.value,
                            )!, // Pink
                            Color.lerp(
                              Colors.white,
                              const Color.fromARGB(255, 144, 176, 237),
                              _animation.value,
                            )!, // Light blue
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds);
                      },
                      child: const Text(
                        'AuraBloom',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                          color: Colors.white, // This serves as the mask
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
