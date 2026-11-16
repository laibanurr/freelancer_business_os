import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freelancer_business_os/screens/auth/auth_gate.dart';
import 'package:freelancer_business_os/screens/onboarding_screen.dart';
import 'package:freelancer_business_os/widgets/app_brand_logo.dart';
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
    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 2000));
    } else {
      await Future.delayed(const Duration(milliseconds: 400));
    }

    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            seenOnboarding ? const AuthGate() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF0F172A);

    return const Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppBrandLogo(size: 88),
            SizedBox(height: 28),
            Text(
              'Freelancer OS',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
