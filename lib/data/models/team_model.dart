enum TeamRole { owner, admin, developer, member }

enum TeamVisibility { public, private }

class TeamModel {
  final String id;
  final String name;
  final TeamVisibility visibility;
  final String? description;
  final TeamRole userRole;
  final int memberCount;

  TeamModel({
    required this.id,
    required this.name,
    required this.visibility,
    this.description,
    required this.userRole,
    this.memberCount =
        1,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
  
    final teamData = json['teamId'] as Map<String, dynamic>;

  
    TeamRole parsedRole = TeamRole.member;
    switch (json['role']) {
      case 'owner':
        parsedRole = TeamRole.owner;
        break;
      case 'admin':
        parsedRole = TeamRole.admin;
        break;
      case 'developer':
        parsedRole = TeamRole.developer;
        break;
    }


    TeamVisibility parsedVisibility = teamData['visibility'] == 'public'
        ? TeamVisibility.public
        : TeamVisibility.private;

    return TeamModel(
      id: teamData['_id'],
      name: teamData['name'],
      description: teamData['description'],
      visibility: parsedVisibility,
      userRole: parsedRole,
      memberCount: 1,
    );
  }
}
