import 'package:code_mate/data/models/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalState {
  static final GlobalState _instance = GlobalState._internal();

  factory GlobalState() {
    return _instance;
  }

  GlobalState._internal();

  String? _accessToken;
  String? _refreshToken;
  UserModel? _currentUser;
  bool _loggedIn = false;

  // Getters
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  UserModel? get currentUser => _currentUser;
  bool get loggedIn => _loggedIn;

  // Called in main.dart before runApp
  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    _loggedIn = prefs.getBool('is_logged_in') ?? false;

    final userJson = prefs.getString('user');
    if (userJson != null && userJson.isNotEmpty) {
      try {
        _currentUser = UserModel.fromJsonString(userJson);
      } catch (e) {
        debugPrint("Failed to parse user JSON on init: $e");
      }
    }
  }

  // THE FIX: Update memory AND disk
  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    _accessToken = access; // <-- Updates RAM
    _refreshToken = refresh; // <-- Updates RAM

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access); // <-- Updates Disk
    await prefs.setString('refresh_token', refresh);
  }

  // THE FIX: Update memory AND disk
  Future<void> saveUserAndStatus(UserModel user) async {
    _currentUser = user; // <-- Updates RAM
    _loggedIn = true; // <-- Updates RAM

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', user.toJsonString()); // <-- Updates Disk
    await prefs.setBool('is_logged_in', true);
  }

  Future<void> clearPrefs() async {
    _accessToken = null;
    _refreshToken = null;
    _currentUser = null;
    _loggedIn = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
