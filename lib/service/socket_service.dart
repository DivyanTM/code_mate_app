import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../core/configs/constants.dart';
import '../../data/sources/global_state.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  void connect() {
    if (isConnected) return;

    final token = GlobalState().accessToken;
    if (token == null) return;

    _socket = IO.io(
      APIConstants.DEV_BASE_URL,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) => debugPrint('🟢 Socket connected'));
    _socket!.onDisconnect((_) => debugPrint('🔴 Socket disconnected'));
    _socket!.onError((e) => debugPrint('❌ Socket error: $e'));
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void joinRoom(String roomId) {
    _socket?.emit('room:join', roomId);
  }

  void leaveRoom(String roomId) {
    _socket?.emit('room:leave', roomId);
  }

  void sendMessage(String roomId, String content) {
    _socket?.emit('message:send', {
      'roomId': roomId,
      'content': content,
      'type': 'text',
    });
  }

  void emitTypingStart(String roomId) {
    _socket?.emit('typing:start', {'roomId': roomId});
  }

  void emitTypingStop(String roomId) {
    _socket?.emit('typing:stop', {'roomId': roomId});
  }

  void markRead(String roomId) {
    _socket?.emit('messages:read', {'roomId': roomId});
  }

  void onNewMessage(void Function(dynamic) handler) {
    _socket?.on('message:new', handler);
  }

  void onTypingStart(void Function(dynamic) handler) {
    _socket?.on('typing:start', handler);
  }

  void onTypingStop(void Function(dynamic) handler) {
    _socket?.on('typing:stop', handler);
  }

  void onMessagesRead(void Function(dynamic) handler) {
    _socket?.on('messages:read', handler);
  }

  void off(String event) {
    _socket?.off(event);
  }
}
