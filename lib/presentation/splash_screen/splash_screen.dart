import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _typewriterController;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  String _displayedText1 = '';
  String _displayedText2 = '';
  final String _fullText1 = 'Made by Aryan, Renuka and Kiran';
  final String _fullText2 = 'With guidance of Dr. G. Ashok Kumar';

  int _currentIndex1 = 0;
  int _currentIndex2 = 0;
  Timer? _typewriterTimer;

  @override
  void initState() {
    super.initState();

    // Fade animation controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Rotation animation controller for spinning logo
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(); // Continuously repeat the rotation

    _rotationAnimation = Tween<double>(begin: 0.0, end: -1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    // Typewriter animation controller
    _typewriterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start fade animation
    _fadeController.forward();

    // Wait a bit, then start typewriter effect
    await Future.delayed(const Duration(milliseconds: 800));
    _startTypewriter();

    // Navigate to landing page after all animations complete
    await Future.delayed(const Duration(milliseconds: 5500));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/landing-page');
    }
  }

  void _startTypewriter() {
    const duration = Duration(milliseconds: 60);

    _typewriterTimer = Timer.periodic(duration, (timer) {
      setState(() {
        if (_currentIndex1 < _fullText1.length) {
          _displayedText1 = _fullText1.substring(0, _currentIndex1 + 1);
          _currentIndex1++;
        } else if (_currentIndex2 < _fullText2.length) {
          _displayedText2 = _fullText2.substring(0, _currentIndex2 + 1);
          _currentIndex2++;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _typewriterController.dispose();
    _rotationController.dispose();
    _typewriterTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1B5E20), // Dark green
              const Color(0xFF2E7D32), // Medium green
              const Color(0xFF4CAF50), // Light green
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spinning Loading Logo
              RotationTransition(
                turns: _rotationAnimation,
                child: Image.asset(
                  'assets/images/loading.png',
                  width: 100.sp,
                  height: 100.sp,
                ),
              ),
              SizedBox(height: 6.h),

              // Credits Section
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  children: [
                    // First line - Made by
                    Text(
                      _displayedText1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Second line - Guidance
                    Text(
                      _displayedText2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.95),
                        letterSpacing: 0.3,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 8.h),

              // Loading indicator
              SizedBox(
                width: 40.w,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
