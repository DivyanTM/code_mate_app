import 'package:code_mate/core/utils/api.dart';
import 'package:code_mate/data/models/user_model.dart';
import 'package:code_mate/data/sources/global_state.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<(bool success, String message)> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _api.post('/auth/login', {
        'email': email,
        'password': password,
      }, authRequired: false);

      final data = response.data['data'];
      final userJson = data['user'];

      // --- BULLETPROOF TOKEN EXTRACTION ---
      String? accessToken;
      String? refreshToken;

      if (data.containsKey('tokens') && data['tokens'] != null) {
        accessToken = data['tokens']['accessToken'];
        refreshToken = data['tokens']['refreshToken'];
      } else {
        accessToken = data['token'] ?? data['accessToken'];
        refreshToken = data['refreshToken'];
      }

      if (accessToken == null || accessToken.isEmpty) {
        return (
          false,
          "Backend did not return a valid token. Check API response.",
        );
      }

      await GlobalState().saveTokens(
        access: accessToken,
        refresh: refreshToken ?? '',
      );

      final user = UserModel.fromJson(userJson);
      await GlobalState().saveUserAndStatus(user);

      debugPrint("✅ LOGIN SUCCESS: Token saved successfully.");
      return (true, 'Login successful');
    } catch (e) {
      final cleanMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint("❌ LOGIN ERROR: $cleanMessage");
      return (false, cleanMessage);
    }
  }

  Future<(bool success, String message)> register({
    required String name,
    required String email,
    required String password,
    required DateTime dateOfBirth,
  }) async {
    try {
      final response = await _api.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'dateOfBirth': dateOfBirth.toIso8601String(),
      }, authRequired: false);

      final data = response.data['data'];
      final userJson = data['user'];

      String? accessToken;
      String? refreshToken;

      if (data.containsKey('tokens') && data['tokens'] != null) {
        accessToken = data['tokens']['accessToken'];
        refreshToken = data['tokens']['refreshToken'];
      } else {
        accessToken = data['token'] ?? data['accessToken'];
        refreshToken = data['refreshToken'];
      }

      await GlobalState().saveTokens(
        access: accessToken ?? '',
        refresh: refreshToken ?? '',
      );

      final user = UserModel.fromJson(userJson);
      await GlobalState().saveUserAndStatus(user);

      return (true, 'Registration successful');
    } catch (e) {
      final cleanMessage = e.toString().replaceAll('Exception: ', '');
      return (false, cleanMessage);
    }
  }

  Future<void> logout() async {
    await GlobalState().clearPrefs();
  }
}
