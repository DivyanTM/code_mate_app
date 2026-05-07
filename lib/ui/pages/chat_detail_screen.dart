import 'package:code_mate/data/models/chat_model.dart';
import 'package:code_mate/data/sources/global_state.dart';
import 'package:code_mate/service/chat_api_service.dart';
import 'package:code_mate/service/socket_service.dart';
import 'package:code_mate/ui/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends StatefulWidget {
  final String roomId;
  final String title;
  final String? subtitle;
  final bool isChannel;

  const ChatDetailScreen({
    super.key,
    required this.roomId,
    required this.title,
    this.subtitle,
    this.isChannel = false,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatApiService _chatService = ChatApiService();
  final SocketService _socket = SocketService();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _someoneTyping = false;
  String _typingUserId = '';

  String get _currentUserId => GlobalState().currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _setupSocket();
  }

  @override
  void dispose() {
    _socket.leaveRoom(widget.roomId);
    _socket.off('message:new');
    _socket.off('typing:start');
    _socket.off('typing:stop');
    _socket.off('messages:read');
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupSocket() {
    _socket.joinRoom(widget.roomId);

    _socket.onNewMessage((data) {
      final message = ChatMessage.fromJson(data as Map<String, dynamic>);

      // 🚀 CRITICAL FIX: Ignore the socket message if YOU sent it.
      // (Because our Optimistic UI already added it to the screen below)
      if (message.sender.id == _currentUserId) return;

      if (!mounted) return;
      setState(() => _messages.add(message));
      _scrollToBottom();

      if (message.sender.id != _currentUserId) {
        _socket.markRead(widget.roomId);
      }
    });

    _socket.onTypingStart((data) {
      final userId = (data as Map)['userId'] as String?;
      if (userId == null || userId == _currentUserId) return;
      if (!mounted) return;
      setState(() {
        _someoneTyping = true;
        _typingUserId = userId;
      });
    });

    _socket.onTypingStop((data) {
      final userId = (data as Map)['userId'] as String?;
      if (userId == _typingUserId && mounted) {
        setState(() => _someoneTyping = false);
      }
    });
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final messages = await _chatService.getMessages(widget.roomId);
      setState(() => _messages = messages);
      await _chatService.markAsRead(widget.roomId);
      _socket.markRead(widget.roomId);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // 🚀 CRITICAL FIX: Save via API first, update UI instantly, then broadcast socket
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    _messageController.clear();
    _socket.emitTypingStop(widget.roomId);
    setState(() => _isSending = true);

    try {
      // 1. Save to MongoDB via REST API
      final savedMessage = await _chatService.sendMessage(widget.roomId, text);

      // 2. Add to screen instantly
      if (mounted) {
        setState(() {
          _messages.add(savedMessage);
          _scrollToBottom();
        });
      }

      // 3. Emit via socket so the other person's phone updates
      _socket.sendMessage(widget.roomId, text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send: ${e.toString().replaceAll('Exception: ', '')}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _onTypingChanged(String value) {
    if (value.isNotEmpty) {
      _socket.emitTypingStart(widget.roomId);
    } else {
      _socket.emitTypingStop(widget.roomId);
    }
  }

  String _formatTime(DateTime dt) => DateFormat('hh:mm a').format(dt);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            if (!widget.isChannel)
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                child: Text(
                  widget.title.isNotEmpty ? widget.title[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 13,
                  ),
                ),
              ),
            if (!widget.isChannel) const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.subtitle != null)
                  Text(
                    widget.subtitle!,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.info_outline), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                ? const Center(
                    child: Text(
                      "No messages yet. Say hello! 👋",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return ChatBubble(
                        message: msg.content,
                        isMe: msg.sender.id == _currentUserId,
                        timestamp: _formatTime(msg.createdAt),
                      );
                    },
                  ),
          ),

          // Typing indicator
          if (_someoneTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "typing...",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
            ),

          // Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: _onTypingChanged,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        filled: true,
                        fillColor: theme.scaffoldBackgroundColor,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
