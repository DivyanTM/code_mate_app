enum ProjectStatus { planning, active, completed, onHold }

class Project {
  final String id;
  final String title;
  final String? description;
  final List<String> techStack;
  final ProjectStatus status;
  final String? linkedTeamId;

  Project({
    required this.id,
    required this.title,
    this.description,
    required this.techStack,
    required this.status,
    this.linkedTeamId,
  });
}
