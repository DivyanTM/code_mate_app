import 'package:code_mate/core/utils/api.dart';
import 'package:code_mate/data/models/project_model.dart';
import 'package:flutter/foundation.dart';

class ProjectService {
  final ApiService _api = ApiService();

  Future<List<Project>> getMyProjects() async {
    try {
      final response = await _api.get('/project/user/me', authRequired: true);

      final List<dynamic> projectsData = response.data['data']['projects'];
      return projectsData.map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching projects: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<(bool success, String message)> createProject({
    required String title,
    String? description,
  }) async {
    try {
      await _api.post('/project', {
        'title': title,
        if (description != null && description.isNotEmpty)
          'description': description,
      }, authRequired: true);

      return (true, 'Project created successfully');
    } catch (e) {
      debugPrint('Error creating project: $e');
      return (false, e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<(bool success, String message)> updateProject({
    required String projectId,
    String? title,
    String? description,
    String? status,
    List<String>? skills,
    String? teamId,
  }) async {
    try {
      await _api.patch('/project/$projectId', {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (status != null) 'status': status,
        if (skills != null) 'skills': skills,
        if (teamId != null) 'teamId': teamId.isEmpty ? null : teamId,
      }, authRequired: true);

      return (true, 'Project updated successfully');
    } catch (e) {
      debugPrint('Error updating project: $e');
      return (false, e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<(bool success, String message)> deleteProject(String projectId) async {
    try {
      await _api.delete('/project/$projectId', authRequired: true);
      return (true, 'Project deleted successfully');
    } catch (e) {
      return (false, e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<dynamic>> getProjectMembers(String projectId) async {
    try {
      final response = await _api.get(
        '/project/$projectId/members',
        authRequired: true,
      );
      return response.data['data']['members'] ?? [];
    } catch (e) {
      debugPrint('Error fetching project members: $e');
      return [];
    }
  } 

  Future<List<String>> getProjectSkills(String projectId) async {
    try {
      final response = await _api.get(
        '/project/$projectId/skills',
        authRequired: true,
      );
      final List<dynamic> skillsData = response.data['data']['skills'] ?? [];
      return skillsData.map((s) => s['skillId']['name'].toString()).toList();
    } catch (e) {
      debugPrint('Error fetching project skills: $e');
      return [];
    }
  }
}
