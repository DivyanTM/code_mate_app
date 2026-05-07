import 'package:code_mate/core/utils/api.dart';
import 'package:code_mate/data/models/chat_model.dart';

class ChatApiService {
  final ApiService _api = ApiService();

  Future<List<ChatRoom>> getMyRooms() async {
    try {
      final response = await _api.get('/chat/rooms');
      final list = response.data['data']['rooms'] as List<dynamic>;
      return list
          .map((e) => ChatRoom.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<ChatRoom> openDM(String targetUserId) async {
    try {
      final response = await _api.post('/chat/rooms/dm/$targetUserId', {});
      final roomData = response.data['data']['room'];
      return ChatRoom.fromJson(roomData as Map<String, dynamic>);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<ChatRoom> openProjectRoom(String projectId) async {
    try {
      final response = await _api.post('/chat/rooms/project/$projectId', {});
      return ChatRoom.fromJson(
        response.data['data']['room'] as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<ChatRoom> openTeamRoom(String teamId) async {
    try {
      final response = await _api.post('/chat/rooms/team/$teamId', {});
      return ChatRoom.fromJson(
        response.data['data']['room'] as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<ChatMessage>> getMessages(
    String roomId, {
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final response = await _api.get(
        '/chat/rooms/$roomId/messages',
        query: {'page': page, 'limit': limit},
      );
      final list = response.data['data']['messages'] as List<dynamic>;
      return list
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> markAsRead(String roomId) async {
    try {
      await _api.patch('/chat/rooms/$roomId/read', {});
    } catch (_) {}
  }

  // 🚀 ADDED THIS NEW METHOD 🚀
  Future<ChatMessage> sendMessage(String roomId, String content) async {
    try {
      final response = await _api.post('/chat/rooms/$roomId/messages', {
        'content': content,
        'type': 'text',
      });
      return ChatMessage.fromJson(
        response.data['data']['message'] as Map<String, dynamic>,
      );
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
