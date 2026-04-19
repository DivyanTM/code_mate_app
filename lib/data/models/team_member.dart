class TeamMemberModel {
  final String mappingId;
  final String userId;
  final String username;
  final String email;
  final String role;
  final DateTime joinedAt;

  TeamMemberModel({
    required this.mappingId,
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
    required this.joinedAt,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    final userObject = json['userId'] ?? {};

    final String email = userObject['email']?.toString() ?? '';

    String username = userObject['username']?.toString() ?? '';

    if (username.trim().isEmpty) {
      username = email.contains('@') ? email.split('@').first : 'Unknown User';
    }

    return TeamMemberModel(
      mappingId: json['_id']?.toString() ?? '',
      userId: userObject['_id']?.toString() ?? '',
      username: username,
      email: email,
      role: json['role']?.toString() ?? 'developer',
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'].toString())
          : DateTime.now(),
    );
  }
}
