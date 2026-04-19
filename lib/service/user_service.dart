import 'dart:io';

import 'package:code_mate/core/utils/api.dart';
import 'package:code_mate/data/models/user_model.dart';
import 'package:dio/dio.dart';

class UserService {
  final ApiService _api = ApiService();

  Future<UserModel> getMyProfile() async {
    try {
      final response = await _api.get('/users/profile/me', authRequired: true);
      return UserModel.fromJson(response.data['data']['user']);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<(bool success, String message)> updateProfile({
    String? name,
    String? headline,
    String? bio,
    String? githubURI,
    String? linkedinURI,
    String? portfolioURI,
    List<String>? skills,
  }) async {
    try {
      await _api.put('/users/profile/basic', {
        if (name != null) 'name': name,
        if (headline != null) 'headline': headline,
        if (bio != null) 'bio': bio,
        if (githubURI != null) 'githubURI': githubURI,
        if (linkedinURI != null) 'linkedinURI': linkedinURI,
        if (portfolioURI != null) 'portfolioURI': portfolioURI,
        if (skills != null) 'skills': skills,
      }, authRequired: true);
      return (true, 'Profile updated successfully');
    } catch (e) {
      return (false, e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Returns the updated UserModel from the server so the caller
  /// always displays exactly what is stored in the database.
  Future<(bool success, String message, UserModel? updatedUser)>
  uploadProfilePicture(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'profilePicture': await MultipartFile.fromFile(imageFile.path),
      });

      final response = await _api.patch(
        '/users/profile/picture',
        formData,
        authRequired: true,
      );

      // Parse the user object returned by the server.
      // It contains the profile picture as a MongoDB Buffer
      // { type: "Buffer", data: [...] } which UserModel.fromJson converts
      // to a Uint8List automatically.
      final updatedUser = UserModel.fromJson(response.data['data']['user']);

      return (true, 'Picture updated successfully', updatedUser);
    } catch (e) {
      return (false, e.toString().replaceAll('Exception: ', ''), null);
    }
  }
}
