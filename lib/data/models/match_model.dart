import 'dart:convert';
import 'dart:typed_data';

class MatchCandidate {
  final String id;
  final String name;
  final String headline;
  final String bio;
  final dynamic profilePicture; // Uint8List or null
  final List<double> lastKnownLocation;
  final double score;
  final List<String> sharedSkills;
  final double? distanceKm;

  MatchCandidate({
    required this.id,
    required this.name,
    required this.headline,
    required this.bio,
    this.profilePicture,
    required this.lastKnownLocation,
    required this.score,
    required this.sharedSkills,
    this.distanceKm,
  });

  factory MatchCandidate.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;

    dynamic pic = user['profilePicture'];
    if (pic != null) {
      if (pic is Map && pic.containsKey('data')) {
        pic = Uint8List.fromList(List<int>.from(pic['data']));
      } else if (pic is String && pic.isNotEmpty && !pic.startsWith('http')) {
        try {
          pic = base64Decode(pic);
        } catch (_) {}
      }
    }

    return MatchCandidate(
      id: user['_id'].toString(),
      name: user['name'] as String? ?? '',
      headline: user['headline'] as String? ?? '',
      bio: user['bio'] as String? ?? '',
      profilePicture: pic,
      lastKnownLocation:
          (user['lastKnownLocation'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      score: (json['score'] as num).toDouble(),
      sharedSkills: List<String>.from(json['sharedSkills'] ?? []),
      distanceKm: json['distanceKm'] != null
          ? (json['distanceKm'] as num).toDouble()
          : null,
    );
  }
}

class MatchResult {
  final String id;
  final String status; // "pending" | "accepted" | "rejected"
  final bool matched; // true when status == "accepted"

  MatchResult({required this.id, required this.status, required this.matched});

  factory MatchResult.fromJson(Map<String, dynamic> json) {
    final match = json['match'] as Map<String, dynamic>;
    return MatchResult(
      id: match['_id'].toString(),
      status: match['status'] as String,
      matched: json['matched'] as bool? ?? false,
    );
  }
}
