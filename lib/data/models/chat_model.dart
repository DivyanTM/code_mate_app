class ChatMessage {
  final String id;
  final String roomId;
  final String content;
  final String type;
  final ChatSender sender;
  final DateTime createdAt;
  final List<String> readBy;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.content,
    required this.type,
    required this.sender,
    required this.createdAt,
    required this.readBy,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'].toString(),
      roomId: json['roomId'].toString(),
      content: json['content'] as String,
      type: json['type'] as String? ?? 'text',
      sender: ChatSender.fromJson(json['sender'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      readBy: List<String>.from(json['readBy'] ?? []),
    );
  }
}

class ChatSender {
  final String id;
  final String name;

  ChatSender({required this.id, required this.name});

  factory ChatSender.fromJson(Map<String, dynamic> json) {
    return ChatSender(
      id: json['_id'].toString(),
      name: json['name'] as String? ?? '',
    );
  }
}

class ChatRoom {
  final String id;
  final String type; // dm | project | team
  final List<RoomParticipant> participants;
  final dynamic reference; // populated project or team
  final ChatMessage? lastMessage;
  final DateTime updatedAt;

  ChatRoom({
    required this.id,
    required this.type,
    required this.participants,
    this.reference,
    this.lastMessage,
    required this.updatedAt,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    final participantsList =
        (json['participants'] as List<dynamic>?)
            ?.map((p) => RoomParticipant.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [];

    ChatMessage? last;
    if (json['lastMessage'] != null && json['lastMessage'] is Map) {
      last = ChatMessage.fromJson(json['lastMessage'] as Map<String, dynamic>);
    }

    return ChatRoom(
      id: json['_id'].toString(),
      type: json['type'] as String,
      participants: participantsList,
      reference: json['reference'],
      lastMessage: last,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  // Display name for the room
  String displayName(String currentUserId) {
    if (type == 'dm') {
      final other = participants.firstWhere(
        (p) => p.id != currentUserId,
        orElse: () => participants.first,
      );
      return other.name;
    }
    if (reference is Map) {
      return (reference as Map)['name'] as String? ?? type;
    }
    return type;
  }
}

class RoomParticipant {
  final String id;
  final String name;

  RoomParticipant({required this.id, required this.name});

  factory RoomParticipant.fromJson(Map<String, dynamic> json) {
    return RoomParticipant(
      id: json['_id'].toString(),
      name: json['name'] as String? ?? '',
    );
  }
}
