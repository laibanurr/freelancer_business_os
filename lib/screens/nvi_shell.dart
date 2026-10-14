import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/screens/clients_screen.dart';
import 'package:freelancer_business_os/screens/dashboard_screen.dart';
import 'package:freelancer_business_os/screens/invoice_screen.dart';
import 'package:freelancer_business_os/screens/projects_screen.dart';
import 'package:freelancer_business_os/screens/settings_screen.dart';
import 'package:freelancer_business_os/screens/chat_screen.dart'; 
import 'package:freelancer_business_os/providers/stream_provider/time_entry_stream_provider.dart';
import 'package:freelancer_business_os/providers/state_provider/theme_provider.dart'; 

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;
  DateTime? _lastAlertTime;

  final _screens = const [
    DashboardScreen(),
    ClientsScreen(),
    ProjectsScreen(),
    InvoicesScreen(),
    ChatScreen(), 
    SettingsScreen(),
  ];

  void _executeBackgroundAlertCheck(WidgetRef ref) {
    final entriesAsync = ref.watch(timeEntriesStreamProvider);
    final entries = entriesAsync.value ?? [];
    final hasActiveTimer = entries.any((e) => e.endTime == null);

    if (hasActiveTimer) {
      final now = DateTime.now();
      if (_lastAlertTime == null || now.difference(_lastAlertTime!).inMinutes >= 15) {
        _lastAlertTime = now;
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.running_with_errors, color: Colors.orangeAccent, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Operational Notice: An active project log stopwatch is currently running background counters. Remember to suspend tracing sessions when offline.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 5),
              backgroundColor: Color(0xFF1E293B),
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _executeBackgroundAlertCheck(ref);
    
    // 🌟 WATCH GLOBAL THEME NOTIFIER: Explicitly updates on every switch toggle [riverpod.dev]
    final isDarkMode = ref.watch(themeProvider);
    
    // Dynamic Token Palette Mapping Matrix
    final backgroundColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final navBarColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final unselectedIconColor = isDarkMode ? Colors.white60 : Colors.grey;
    const primaryIndigo = Color(0xFF4F46E5);

    return Scaffold(
      backgroundColor: backgroundColor,
      // 🌟 ROOT LEVEL BOUNDARY: Directly loads full width un-centered scaffold canvases
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.08), 
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          backgroundColor: navBarColor, // 🌟 FIXED: Swaps container color matching system settings natively!
          indicatorColor: primaryIndigo.withValues(alpha: 0.08), 
          selectedIndex: _index,
          elevation: 0, 
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined, color: unselectedIconColor),
              selectedIcon: const Icon(Icons.grid_view_rounded, color: primaryIndigo), 
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.group_outlined, color: unselectedIconColor),
              selectedIcon: const Icon(Icons.group_rounded, color: primaryIndigo),
              label: 'Clients',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_open_outlined, color: unselectedIconColor),
              selectedIcon: const Icon(Icons.folder_rounded, color: primaryIndigo),
              label: 'Projects',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined, color: unselectedIconColor),
              selectedIcon: const Icon(Icons.receipt_long_rounded, color: primaryIndigo),
              label: 'Billing',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined, color: unselectedIconColor),
              selectedIcon: const Icon(Icons.auto_awesome_rounded, color: primaryIndigo),
              label: 'Gemini AI',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: unselectedIconColor),
              selectedIcon: const Icon(Icons.person_rounded, color: primaryIndigo),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
