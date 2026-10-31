import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/providers/auth_state_provider.dart';
import 'package:freelancer_business_os/screens/auth/login_screen.dart';
import 'package:freelancer_business_os/screens/nvi_shell.dart';

const _primaryIndigo = Color(0xFF4F46E5);

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) => user == null ? const LoginScreen() : const MainShell(),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Text(
            'Authentication Error: $error',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: _primaryIndigo),
        ),
      ),
    );
  }
}