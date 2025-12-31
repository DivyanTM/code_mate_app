enum TeamRole { owner, admin, member }

enum TeamVisibility { private, inviteOnly, public }

class Team {
  final String id;
  final String name;
  final TeamRole userRole;
  final int memberCount;
  final TeamVisibility visibility;

  Team({
    required this.id,
    required this.name,
    required this.userRole,
    required this.memberCount,
    required this.visibility,
  });
}
