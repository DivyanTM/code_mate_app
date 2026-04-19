import 'package:code_mate/core/utils/api.dart';
import 'package:code_mate/data/models/match_model.dart';
import 'package:flutter/foundation.dart';

class MatchService {
  final ApiService _api = ApiService();

  /// Fetches ranked candidates from the server.
  Future<List<MatchCandidate>> getCandidates({
    double maxDistanceKm = 100,
    int limit = 20,
  }) async {
    try {
      // ApiService.get() uses named param 'query' (not 'queryParameters').
      final response = await _api.get(
        '/match/candidates',
        query: {'maxDistanceKm': maxDistanceKm, 'limit': limit},
        authRequired: true,
      );
      final list = response.data['data']['candidates'] as List<dynamic>;
      return list
          .map((e) => MatchCandidate.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Like a user. Returns [MatchResult] which tells you if it's a mutual match.
  Future<MatchResult> likeUser(String targetId) async {
    try {
      final response = await _api.post(
        '/match/like/$targetId',
        {},
        authRequired: true,
      );
      return MatchResult.fromJson(response.data['data']);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  /// Reject / pass on a user. Silently ignores "already interacted" errors.
  Future<void> rejectUser(String targetId) async {
    try {
      await _api.post('/match/reject/$targetId', {}, authRequired: true);
    } catch (e) {
      debugPrint('Reject error (ignored): $e');
    }
  }
}
