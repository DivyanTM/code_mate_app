import 'package:code_mate/core/utils/api.dart';
import 'package:code_mate/data/models/team_member.dart';
import 'package:code_mate/data/models/team_model.dart';
import 'package:flutter/foundation.dart';

class TeamService {
  final ApiService _api = ApiService();

  Future<List<TeamModel>> getMyTeams() async {
    try {
      final response = await _api.get('/team/user/me', authRequired: true);

      final List<dynamic> teamsData = response.data['data']['teams'];

      return teamsData.map((json) => TeamModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching teams: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<(bool success, String message)> createTeam({
    required String name,
    required String visibility,
    String? description,
  }) async {
    try {
      await _api.post('/team', {
        'name': name,
        'visibility': visibility,
        if (description != null && description.isNotEmpty)
          'description': description,
      }, authRequired: true);

      return (true, 'Team created successfully');
    } catch (e) {
      debugPrint('Error creating team: $e');
      final cleanMessage = e.toString().replaceAll('Exception: ', '');
      return (false, cleanMessage);
    }
  }

  Future<(bool success, String message)> updateTeam({
    required String teamId,
    String? name,
    String? description,
    List<String>? skills,
  }) async {
    try {
      await _api.patch('/team/$teamId', {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (skills != null) 'skills': skills,
      }, authRequired: true);
      return (true, 'Team settings saved successfully');
    } catch (e) {
      debugPrint('Error updating team: $e');
      return (false, e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<(bool success, String message)> deleteTeam(String teamId) async {
    try {
      await _api.delete('/team/$teamId', authRequired: true);

      return (true, 'Team deleted successfully');
    } catch (e) {
      debugPrint('Error deleting team: $e');
      return (false, e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<String>> getTeamSkills(String teamId) async {
    try {
      final response = await _api.get(
        '/team/$teamId/skills',
        authRequired: true,
      );

      final List<dynamic> skillsData = response.data['data']['skills'];

      return skillsData.map((s) => s['skillId']['name'].toString()).toList();
    } catch (e) {
      debugPrint('Error fetching team skills: $e');
      return [];
    }
  }

  Future<(bool success, String message)> addTeamMember({
    required String teamId,
    required String identifier,
    required String role,
  }) async {
    try {
      await _api.post('/team/$teamId/members', {
        'identifier': identifier,
        'role': role,
      }, authRequired: true);
      return (true, 'Member added successfully');
    } catch (e) {
      debugPrint('Error adding member: $e');
      return (false, e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<TeamMemberModel>> getTeamMembers(String teamId) async {
    try {
      final response = await _api.get(
        '/team/$teamId/members',
        authRequired: true,
      );
      final List<dynamic> membersData = response.data['data']['members'];
      return membersData.map((json) => TeamMemberModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching members: $e');
      return [];
    }
  }

  Future<(bool success, String message)> updateMemberRole(
    String teamId,
    String memberId,
    String newRole,
  ) async {
    try {
      await _api.patch('/team/$teamId/members/$memberId', {
        'role': newRole,
      }, authRequired: true);
      return (true, 'Member role updated');
    } catch (e) {
      debugPrint('Error updating role: $e');
      return (false, e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<(bool success, String message)> removeTeamMember(
    String teamId,
    String memberId,
  ) async {
    try {
      await _api.delete('/team/$teamId/members/$memberId', authRequired: true);
      return (true, 'Member removed successfully');
    } catch (e) {
      debugPrint('Error removing member: $e');
      return (false, e.toString().replaceAll('Exception: ', ''));
    }
  }
}
