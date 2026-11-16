import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<bool> {
  // Start with default, then immediately load saved choice from disk!
  ThemeNotifier() : super(false) {
    _loadThemeFromDisk();
  }

  // 📖 Reads the saved theme when the app boots
  Future<void> _loadThemeFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('saved_is_dark_mode') ?? false;
  }

  // 💾 Saves the theme whenever you toggle the switch
  Future<void> toggleTheme() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('saved_is_dark_mode', state);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});