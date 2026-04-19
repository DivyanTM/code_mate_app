import 'package:flutter/material.dart';

enum ProjectStatus { active, inactive }

class Project {
  final String id;
  final String title;
  final String? description;
  final ProjectStatus status;
  final List<String> techStack;
  final String? linkedTeamId;

  Project({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.techStack = const [],
    this.linkedTeamId,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    // Check if the data is nested inside 'projectId' (from getProjectsByUser)
    final data = json['projectId'] is Map<String, dynamic>
        ? json['projectId']
        : json;

    ProjectStatus parsedStatus = ProjectStatus.inactive;
    if (data['status']?.toString().toLowerCase() == 'active') {
      parsedStatus = ProjectStatus.active;
    }

    // Safely extract the linkedTeamId
    final String? teamId = data['linkedTeamId']?.toString();

    // DEBUG: Print what we are receiving
    debugPrint("Parsed Project '${data['title']}': linkedTeamId = $teamId");

    return Project(
      id: data['_id']?.toString() ?? '',
      title: data['title']?.toString() ?? 'Untitled Project',
      description: data['description']?.toString(),
      status: parsedStatus,
      linkedTeamId: teamId,
      techStack: [],
    );
  }
}
