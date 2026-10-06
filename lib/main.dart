import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freelancer_business_os/firebase_options.dart';
import 'package:freelancer_business_os/providers/state_provider/theme_provider.dart';
import 'package:freelancer_business_os/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final isDarkMode = ref.watch(themeProvider);
    
    return MaterialApp(
      title: 'Freelancer Business OS',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), 
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), 
          brightness: Brightness.light,
        ),
      ),
      
      
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A), 
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), 
          brightness: Brightness.dark,
        ),
      ),
      
      home: const SplashScreen(),
    );
  }
}
