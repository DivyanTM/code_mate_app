import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class GlobalState {
  static final GlobalState _instance = GlobalState._internal();

  factory GlobalState() => _instance;

  GlobalState._internal();

  bool loggedIn = false;
  String? accessToken;
  String? refreshToken;
  UserModel? currentUser;

  Future<void> loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    loggedIn = prefs.getBool('loggedIn') ?? false;
    accessToken = prefs.getString('accessToken');
    refreshToken = prefs.getString('refreshToken');

    final userJsonStr = prefs.getString('currentUser');
    if (userJsonStr != null && userJsonStr.isNotEmpty) {
      try {
        currentUser = UserModel.fromJsonString(userJsonStr);
      } catch (e) {
        currentUser = null;
        loggedIn = false;
      }
    } else {
      loggedIn = false;
    }
  }


  Future<bool> saveTokens({
    required String access,
    required String refresh,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = access;
    refreshToken = refresh;

    final bool accessSaved = await prefs.setString('accessToken', access);
    final bool refreshSaved = await prefs.setString('refreshToken', refresh);

    return accessSaved && refreshSaved;
  }

  Future<bool> updateAccessToken(String newAccessToken) async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = newAccessToken;
    return prefs.setString('accessToken', newAccessToken);
  }

  Future<bool> saveUserAndStatus(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    currentUser = user;
    loggedIn = true;

    final bool userSaved = await prefs.setString(
      'currentUser',
      user.toJsonString(),
    );
    final bool statusSaved = await prefs.setBool('loggedIn', true);

    return userSaved && statusSaved;
  }

  Future<bool> clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cleared = await prefs.clear();

    if (cleared) {
      loggedIn = false;
      accessToken = null;
      refreshToken = null;
      currentUser = null;
    }

    return cleared;
  }
}
