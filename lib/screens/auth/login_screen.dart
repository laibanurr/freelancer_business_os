import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/screens/sign_up_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } on FirebaseException catch (e) {
      setState(() {
        _errorMessage = switch (e.code) {
          'weak-password' => 'Password should be at least 6 characters.',
          'email-already-in-use' => 'An account already exists for that email.',
          'invalid-email' => 'That email address looks invalid.',
          'wrong-password' => 'Incorrect password.',
          'user-not-found' => 'No account found for that email.',
          _ => 'Something went wrong: ${e.message}',
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: .center,
        crossAxisAlignment: .stretch,
         children: [
          const Text('Welcome back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                SizedBox( height: 32),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16,),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            if(_errorMessage != null)...[
              SizedBox(height: 12,),
              Text(_errorMessage! , style: TextStyle(color: Colors.red),)
            ],
            const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Log in'),
              ),
              SizedBox(height:14),
              TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpScreen()),
    );
  },
  child: const Text("Don't have an account? Sign up"),
),
],
      
 ),),
        ), 
    );
  }
}
