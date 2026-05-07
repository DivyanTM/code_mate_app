import 'package:code_mate/data/models/chat_model.dart';
import 'package:code_mate/data/sources/global_state.dart';
import 'package:code_mate/service/chat_api_service.dart';
import 'package:code_mate/ui/pages/chat_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ChatApiService _chatService = ChatApiService();

  List<ChatRoom> _dmRooms = [];
  List<ChatRoom> _channelRooms = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRooms();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final rooms = await _chatService.getMyRooms();
      setState(() {
        _dmRooms = rooms.where((r) => r.type == 'dm').toList();
        _channelRooms = rooms
            .where((r) => r.type == 'team' || r.type == 'project')
            .toList();
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMM d').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Messages"),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.edit_square), onPressed: () {}),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: "Direct Messages"),
            Tab(text: "Channels"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _loadRooms,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRoomList(theme, _dmRooms, isDM: true),
                _buildRoomList(theme, _channelRooms, isDM: false),
              ],
            ),
    );
  }

  Widget _buildRoomList(
    ThemeData theme,
    List<ChatRoom> rooms, {
    required bool isDM,
  }) {
    if (rooms.isEmpty) {
      return Center(
        child: Text(
          isDM ? "No direct messages yet." : "No channels yet.",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final currentUserId = GlobalState().currentUser?.id ?? '';

    return RefreshIndicator(
      onRefresh: _loadRooms,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: rooms.length,
        separatorBuilder: (_, __) => const Divider(height: 24, thickness: 0.5),
        itemBuilder: (context, index) {
          final room = rooms[index];
          final name = room.displayName(currentUserId);
          final lastMsg = room.lastMessage?.content ?? '';
          final time = _formatTime(
            room.lastMessage?.createdAt ?? room.updatedAt,
          );

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: isDM
                ? CircleAvatar(
                    radius: 26,
                    backgroundColor: theme.colorScheme.primary.withOpacity(
                      0.15,
                    ),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      room.type == 'team'
                          ? Icons.group_rounded
                          : Icons.work_outline_rounded,
                      color: theme.colorScheme.primary,
                    ),
                  ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              lastMsg.isEmpty ? 'No messages yet' : lastMsg,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Text(
              time,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatDetailScreen(
                  roomId: room.id,
                  title: name,
                  isChannel: !isDM,
                  subtitle: room.type == 'team'
                      ? 'Team'
                      : room.type == 'project'
                      ? 'Project'
                      : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
