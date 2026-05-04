import 'package:code_mate/core/utils/api.dart';
import 'package:code_mate/data/models/match_model.dart';
import 'package:flutter/foundation.dart';

class MatchService {
  final ApiService _api = ApiService();

  Future<List<MatchCandidate>> getCandidates({
    double maxDistanceKm = 100,
    int limit = 20,
  }) async {
    try {
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

  Future<void> rejectUser(String targetId) async {
    try {
      await _api.post('/match/reject/$targetId', {}, authRequired: true);
    } catch (e) {
      debugPrint('Reject error (ignored): $e');
    }
  }
}
