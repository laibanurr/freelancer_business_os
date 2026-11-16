import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/providers/state_provider/theme_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/project_stream_provider.dart';
import 'package:freelancer_business_os/providers/stream_provider/time_entry_stream_provider.dart';
import 'package:freelancer_business_os/screens/chat_screen.dart';
import 'package:freelancer_business_os/screens/clients_screen.dart';
import 'package:freelancer_business_os/screens/dashboard_screen.dart';
import 'package:freelancer_business_os/screens/invoice_screen.dart';
import 'package:freelancer_business_os/screens/projects_screen.dart';
import 'package:freelancer_business_os/screens/settings_screen.dart';
import 'package:freelancer_business_os/screens/time_entries_screen.dart';

const _primaryIndigo = Color(0xFF4F46E5);

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

    final runningEntry = entries.where((e) => e.endTime == null).firstOrNull;

    if (runningEntry != null) {
      final now = DateTime.now();
      if (_lastAlertTime == null ||
          now.difference(_lastAlertTime!).inMinutes >= 15) {
        _lastAlertTime = now;

        final projects = ref.read(projectsStreamProvider).value ?? [];
        final activeProject = projects
            .where((p) => p.id == runningEntry.projectId)
            .firstOrNull;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: _primaryIndigo, 
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              duration: const Duration(seconds: 8),
              content: Row(
                children: [
                  const Icon(Icons.timer_outlined,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Timer running: ${activeProject?.projectName ?? "Active Session"}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (activeProject != null)
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TimeEntriesScreen(project: activeProject),
                          ),
                        );
                      },
                      child: const Text('OPEN',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white70, size: 18),
                    onPressed: () =>
                        ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  ),
                ],
              ),
            ),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _executeBackgroundAlertCheck(ref);

    final isDarkMode = ref.watch(themeProvider);
    final backgroundColor =
        isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final navBarColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final unselectedIconColor = isDarkMode ? Colors.white60 : Colors.grey;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          backgroundColor: navBarColor,
          indicatorColor: _primaryIndigo.withValues(alpha: 0.12),
          
          indicatorShape: const CircleBorder(),
          selectedIndex: _index,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined, color: unselectedIconColor),
              selectedIcon:
                  const Icon(Icons.grid_view_rounded, color: _primaryIndigo),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.group_outlined, color: unselectedIconColor),
              selectedIcon:
                  const Icon(Icons.group_rounded, color: _primaryIndigo),
              label: 'Clients',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_open_outlined, color: unselectedIconColor),
              selectedIcon:
                  const Icon(Icons.folder_rounded, color: _primaryIndigo),
              label: 'Projects',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined,
                  color: unselectedIconColor),
              selectedIcon:
                  const Icon(Icons.receipt_long_rounded, color: _primaryIndigo),
              label: 'Billing',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined,
                  color: unselectedIconColor),
              selectedIcon:
                  const Icon(Icons.auto_awesome_rounded, color: _primaryIndigo),
              label: 'Gemini AI',
            ),
            NavigationDestination(
              icon:
                  Icon(Icons.person_outline_rounded, color: unselectedIconColor),
              selectedIcon:
                  const Icon(Icons.person_rounded, color: _primaryIndigo),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}