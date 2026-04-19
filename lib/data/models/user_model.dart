import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final String email;
  final String bio;
  final dynamic profilePicture;
  final String headline;
  final String githubURI;
  final String linkedinURI;
  final String portfolioURI;
  final List<double> lastKnownLocation;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String status;

  UserModel({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.email,
    required this.bio,
    this.profilePicture,
    required this.headline,
    required this.githubURI,
    required this.linkedinURI,
    required this.portfolioURI,
    required this.lastKnownLocation,
    required this.createdAt,
    this.updatedAt,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      email: json['email'] as String,
      bio: json['bio'] as String? ?? '',
      profilePicture: json['profilePicture'],
      headline: json['headline'] as String? ?? '',
      githubURI: json['githubURI'] as String? ?? '',
      linkedinURI: json['linkedinURI'] as String? ?? '',
      portfolioURI: json['portfolioURI'] as String? ?? '',
      lastKnownLocation:
          (json['lastKnownLocation'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'email': email,
      'bio': bio,
      'profilePicture': profilePicture,
      'headline': headline,
      'githubURI': githubURI,
      'linkedinURI': linkedinURI,
      'portfolioURI': portfolioURI,
      'lastKnownLocation': lastKnownLocation,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String source) =>
      UserModel.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
