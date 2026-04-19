import 'dart:convert';
import 'dart:typed_data';

class UserModel {
  final String id;
  final String name;
  final DateTime dateOfBirth;
  final String email;
  final String bio;
  final dynamic
  profilePicture; // Uint8List (decoded bytes) or String (http URL) or null
  final String headline;
  final String githubURI;
  final String linkedinURI;
  final String portfolioURI;
  final List<double> lastKnownLocation;
  final List<String> skills;
  final List<Map<String, dynamic>> experience;
  final DateTime createdAt;
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
    required this.skills,
    required this.experience,
    required this.createdAt,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    dynamic processedImage = json['profilePicture'];

    if (processedImage != null) {
      // Shape 1: MongoDB Buffer sent as { type: "Buffer", data: [bytes...] }
      if (processedImage is Map && processedImage.containsKey('data')) {
        processedImage = Uint8List.fromList(
          List<int>.from(processedImage['data']),
        );
      }
      // Shape 2: Raw base64 string (e.g. "iVBORw0KGgo...")
      // The server serialises the binary field directly as a base64 string
      // when JSON.stringify encounters a Buffer — detect and decode it.
      else if (processedImage is String &&
          !processedImage.startsWith('http') &&
          processedImage.isNotEmpty) {
        try {
          processedImage = base64Decode(processedImage);
        } catch (_) {
          // Not valid base64 — leave as-is; the image provider will fall back.
        }
      }
      // Shape 3: http/https URL string — left unchanged.
    }

    return UserModel(
      id: json['_id'] as String,
      name: json['name'] as String,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : DateTime.now(),
      email: json['email'] as String,
      bio: json['bio'] as String? ?? '',
      profilePicture: processedImage,
      headline: json['headline'] as String? ?? '',
      githubURI: json['githubURI'] as String? ?? '',
      linkedinURI: json['linkedinURI'] as String? ?? '',
      portfolioURI: json['portfolioURI'] as String? ?? '',
      lastKnownLocation:
          (json['lastKnownLocation'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      skills: List<String>.from(json['skills'] ?? []),
      experience: List<Map<String, dynamic>>.from(json['experience'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
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
      // Don't serialise binary bytes back to SharedPreferences —
      // they'd be massive and will be re-fetched from the server anyway.
      'profilePicture': profilePicture is Uint8List ? null : profilePicture,
      'headline': headline,
      'githubURI': githubURI,
      'linkedinURI': linkedinURI,
      'portfolioURI': portfolioURI,
      'lastKnownLocation': lastKnownLocation,
      'skills': skills,
      'experience': experience,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory UserModel.fromJsonString(String source) =>
      UserModel.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
