import 'package:code_mate/core/utils/api.dart';
import 'package:code_mate/data/models/user_model.dart';
import 'package:code_mate/data/sources/global_state.dart';

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
      final tokens = data['tokens'];

      await GlobalState().saveTokens(
        access: tokens['accessToken'],
        refresh: tokens['refreshToken'],
      );

      final user = UserModel.fromJson(userJson);
      await GlobalState().saveUserAndStatus(user);

      return (true, 'Login successful');
    } catch (e) {
      final cleanMessage = e.toString().replaceAll('Exception: ', '');
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
      final tokens = data['tokens'];

      await GlobalState().saveTokens(
        access: tokens['accessToken'],
        refresh: tokens['refreshToken'],
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
