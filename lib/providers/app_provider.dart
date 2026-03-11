import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _notificationsMuted = false;
  double _userWeight = 0.0;
  int _notificationCount = 3;
  String _language = 'ar'; // 'ar' or 'en'

  bool get isDarkMode => _isDarkMode;
  bool get notificationsMuted => _notificationsMuted;
  double get userWeight => _userWeight;
  int get notificationCount => _notificationCount;
  String get language => _language;
  bool get isArabic => _language == 'ar';

  AppProvider() {
    _loadPreferences();
  }

  // ─── Localisation helper ───────────────────────────────────────────────────
  String t(String arText, String enText) => isArabic ? arText : enText;

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    _notificationsMuted = prefs.getBool('mutedNotifications') ?? false;
    _userWeight = prefs.getDouble('userWeight') ?? 0.0;
    _language = prefs.getString('language') ?? 'ar';
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> toggleNotifications() async {
    _notificationsMuted = !_notificationsMuted;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mutedNotifications', _notificationsMuted);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
  }

  Future<void> setUserWeight(double weight) async {
    _userWeight = weight;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('userWeight', weight);
    notifyListeners();
  }

  void decrementNotifications() {
    if (_notificationCount > 0) {
      _notificationCount--;
      notifyListeners();
    }
  }

  void clearNotifications() {
    _notificationCount = 0;
    notifyListeners();
  }

  Map<String, double> getWeightLossStats() {
    if (_userWeight <= 0) return {};
    double weeklyLoss = _userWeight * 0.005;
    double monthlyLoss = weeklyLoss * 4;
    double threeMonthLoss = monthlyLoss * 3;
    return {
      'weekly': weeklyLoss,
      'monthly': monthlyLoss,
      'threeMonths': threeMonthLoss,
    };
  }
}
