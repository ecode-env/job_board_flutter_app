import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_board_flutter_app/utils/theme.dart';

class ThemeService with ChangeNotifier {
  final String _key = 'theme_mode';
  late SharedPreferences _prefs;
  late ThemeMode _themeMode;
  
  ThemeMode get themeMode => _themeMode;
  ThemeData get lightTheme => AppTheme.lightTheme;
  ThemeData get darkTheme => AppTheme.darkTheme;
  
  ThemeService() {
    _themeMode = ThemeMode.system;
    _loadFromPrefs();
  }
  
  // Load theme mode from shared preferences
  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    int value = _prefs.getInt(_key) ?? 0;
    _themeMode = _intToThemeMode(value);
    notifyListeners();
  }
  
  // Save theme mode to shared preferences
  Future<void> _saveToPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _prefs.setInt(_key, _themeModeToInt(_themeMode));
  }
  
  // Convert ThemeMode to int for storage
  int _themeModeToInt(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
      default:
        return 0;
    }
  }
  
  // Convert int to ThemeMode
  ThemeMode _intToThemeMode(int value) {
    switch (value) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
  
  // Toggle between light and dark theme
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveToPrefs();
    notifyListeners();
  }
  
  // Set a specific theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveToPrefs();
    notifyListeners();
  }
  
  // Check if current theme is dark
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
}