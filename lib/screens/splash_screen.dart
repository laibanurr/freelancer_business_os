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
    
    await Future.delayed(const Duration(seconds: 2));
    final prefs = await SharedPreferences.getInstance();
    final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    
    if (!mounted) return;
    
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => seenOnboarding ? const AuthGate() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    const primaryIndigo = Color(0xFF4F46E5);

    return Scaffold(
      backgroundColor: primaryIndigo, 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome, 
                size: 64,
                color: primaryIndigo, 
              ),
            ),
            const SizedBox(height: 28),
            
            
            const Text(
              'Freelancer OS',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white, 
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
