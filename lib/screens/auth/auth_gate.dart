import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/providers/auth_state_provider.dart';
import 'package:freelancer_business_os/screens/auth/login_screen.dart';
import 'package:freelancer_business_os/screens/nvi_shell.dart';

class AuthGate extends ConsumerWidget {
    const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
        data: (user) => user == null
          ?  const LoginScreen() 
          : const  MainShell() ,
      error: (error, stackTrace) => Center(
        child: Text('Error: $error'),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
