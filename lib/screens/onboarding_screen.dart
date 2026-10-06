import 'package:flutter/material.dart';
import 'package:freelancer_business_os/screens/auth/auth_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0; 
  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Time is Your Currency',
      'description':
          'Log billable hours down to the minute with our smart, distraction-free native stopwatch tracker engine.',
      'icon': Icons.timer_outlined,
    },
    {
      'title': 'Get Paid on Time',
      'description':
          'Compile tracked hours into clean, professional digital invoice statements instantly. Zero manual paperwork.',
      'icon': Icons.receipt_long_outlined,
    },
    {
      'title': 'Know Your Metrics',
      'description':
          'Monitor your active revenue pipelines, outstanding client balances, and monthly growth overview indicators.',
      'icon': Icons.bar_chart_outlined,
    },
  ];
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthGate()),
    );
  }
  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF8FAFC);
    const primaryIndigo = Color(0xFF4F46E5);
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                            color: primaryIndigo.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _onboardingData[index]['icon'] as IconData,
                            size: 80,
                            color: primaryIndigo, 
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          _onboardingData[index]['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _onboardingData[index]['description'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8, 
                        decoration: BoxDecoration(
                          color: _currentPage == index ? primaryIndigo : Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        _completeOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic, 
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryIndigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == _onboardingData.length - 1 ? 'Get Started' : 'Next',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
