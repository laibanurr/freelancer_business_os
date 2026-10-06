import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/screens/clients_screen.dart';
import 'package:freelancer_business_os/screens/dashboard_screen.dart';
import 'package:freelancer_business_os/screens/invoice_screen.dart';
import 'package:freelancer_business_os/screens/projects_screen.dart';
import 'package:freelancer_business_os/screens/settings_screen.dart';
import 'package:freelancer_business_os/providers/state_provider/theme_provider.dart'; 


class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;
  
  
  final _screens = const [
    DashboardScreen(),
    ClientsScreen(),
    ProjectsScreen(),
    InvoicesScreen(),
    SettingsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    
    final isDarkMode = ref.watch(themeProvider);

    
    final backgroundColor = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final borderColor = isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey.withValues(alpha: 0.1);
    final iconUnselectedColor = isDarkMode ? Colors.grey : Colors.grey.shade500;
    const primaryIndigo = Color(0xFF4F46E5);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: NavigationBar(
          backgroundColor: backgroundColor, 
          indicatorColor: primaryIndigo.withValues(alpha: 0.08), 
          selectedIndex: _index,
          elevation: 0, 
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.dashboard, color: primaryIndigo), 
              label: 'Dashboard',
            ),
            const NavigationDestination(
              icon: Icon(Icons.people_outline, color: Colors.grey),
              selectedIcon: Icon(Icons.people, color: primaryIndigo),
              label: 'Clients',
            ),
            const NavigationDestination(
              icon: Icon(Icons.work_outline, color: Colors.grey),
              selectedIcon: Icon(Icons.work, color: primaryIndigo),
              label: 'Projects',
            ),
            const NavigationDestination(
              icon: Icon(Icons.receipt_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.receipt, color: primaryIndigo),
              label: 'Invoices',
            ),
            
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: iconUnselectedColor),
              selectedIcon: const Icon(Icons.settings, color: primaryIndigo),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
