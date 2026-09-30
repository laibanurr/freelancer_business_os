import 'package:flutter/material.dart';
import 'package:freelancer_business_os/screens/auth/auth_gate.dart';
import 'package:freelancer_business_os/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
     _decide();
  }

  Future<void> _decide() async {
    await Future.delayed(Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => seenOnboarding ? AuthGate() : OnboardingScreen()));
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      // 1. Give it a premium dark or custom primary brand background color
      backgroundColor: Colors.blue, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 2. Put a beautiful app graphic icon or logo image here
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome, // Your "✨" magic sparkle app accent icon
                size: 64,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            // 3. Your professional styled application branding text
            const Text(
              'Freelancer OS',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Crisp white contrast typography text
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  }

