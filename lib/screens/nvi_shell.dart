import 'package:flutter/material.dart';
import 'package:freelancer_business_os/screens/clients_screen.dart';
import 'package:freelancer_business_os/screens/dashboard_screen.dart';
import 'package:freelancer_business_os/screens/invoice_screen.dart';
import 'package:freelancer_business_os/screens/projects_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _screens = [
    const DashboardScreen(),
    ClientsScreen(),
    ProjectsScreen(),
    InvoicesScreen()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index,
      children: _screens,),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
       onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
           NavigationDestination(icon: Icon(Icons.people), label: 'Clients'),
          NavigationDestination(icon: Icon(Icons.work), label: 'Projects'),
          NavigationDestination(icon: Icon(Icons.receipt), label: 'Invoices'),
        ]
      
    ));
  }
}
