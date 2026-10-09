import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _themeModeKey = 'theme_mode';

  final SharedPreferences _preferences;
  ThemeMode _themeMode;

  ThemeProvider(this._preferences)
      : _themeMode = _readThemeMode(_preferences);

  static ThemeMode _readThemeMode(SharedPreferences preferences) {
    return preferences.getString(_themeModeKey) == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }

    notifyListeners();
    _saveThemeMode();
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
    _saveThemeMode();
  }

  Future<void> _saveThemeMode() async {
    await _preferences.setString(
      _themeModeKey,
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}