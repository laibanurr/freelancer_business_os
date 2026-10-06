import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;
  bool _obsecurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _errorMessage = null);
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = switch (e.code) {
          'weak-password' => 'Password should be at least 6 characters.',
          'email-already-in-use' => 'An account already exists for that email.',
          'invalid-email' => 'That email address looks invalid.',
          'wrong-password' => 'Incorrect password.',
          'user-not-found' => 'No account found for that email.',
          _ => e.message ?? 'Registerationfailed . please try again.',
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFF8FAFC);
    const primaryIndigo = Color(0xFF4F46E5);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new,
                size: 20, color: Colors.black87)),
      ),
      body: SafeArea(
          child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 28.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Create your account',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5),
                ),
                SizedBox(
                  height: 8,
                ),
                const Text(
                  'Get started by setting up your central business profile workspace.',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                CustomTextField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  label: 'Full Name',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (v.trim().length < 2) {
                      return ' Pleae Enter your full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                CustomTextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  label: 'Email Address',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Enter email Address';
                    }
                    final emailRegex = RegExp(
                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

                    if (!emailRegex.hasMatch(v.trim())) {
                      return 'Enter valid Email Address';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                CustomTextField(
                  controller: _passwordController,
                  textInputAction: TextInputAction.next,
                  obsecureText: _obsecurePassword,
                  label: 'Password (min 6 characters)',
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obsecurePassword = !_obsecurePassword;
                        });
                      },
                      icon: Icon(_obsecurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                          color: Colors.grey,
                          size: 20,)),
                          validator: (v){
                            if (v == null || v.isEmpty) return 'Password is required';
                            if (v.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                ),
                const SizedBox(height: 16,),
                CustomTextField(
                  controller: _confirmPasswordController,
                    obsecureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    label: 'Confirm Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please confirm your password';
                      if (v != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                ),
                 if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  ElevatedButton(onPressed: _signUp, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryIndigo,
                    foregroundColor: Colors.white,
                   elevation: 0,
                   padding: EdgeInsets.symmetric(vertical: 16),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: Text('create workspace Account',
                  style: TextStyle(fontWeight: FontWeight.bold,
                  fontSize: 16),)),
                  const SizedBox(height:20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     Text( 'Already have an account? ',
                      style: TextStyle(color: Colors.grey)),
                     GestureDetector(
                      onTap:()=> Navigator.pop(context),
                      child: Text('Log In',
                          style: TextStyle(color: primaryIndigo, fontWeight: FontWeight.bold),),

                     )

                    ],
                  )
              ],
            ),
          ),
        ),
      )),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final IconButton? suffixIcon;
  final TextInputAction? textInputAction;
  final TextEditingController controller;
  final bool? obsecureText;

  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  const CustomTextField(
      {super.key,
      required this.controller,
      this.inputFormatters,
      this.suffixIcon,
      this.keyboardType,
      this.obsecureText,
      required this.label,
      this.textInputAction,
      this.validator});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      obscureText: obsecureText?? false,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: Color(0xFF4F46E5)),
        filled: true,
        fillColor: Colors.grey.withValues(alpha: 0.03),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4F46E5), width: 2.0),
            borderRadius: BorderRadius.circular(12)),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.redAccent,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12)),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
