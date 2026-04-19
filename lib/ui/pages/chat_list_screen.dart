import 'package:flutter/material.dart';

import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Messages"),
        centerTitle: false, // Left aligned looks more "Slack-like"
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.edit_square),
            onPressed: () {},
          ), // New Chat
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: "Direct Messages"),
            Tab(text: "Team Channels"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildDMList(theme), _buildChannelList(theme)],
      ),
    );
  }

  // 1. Direct Messages List
  Widget _buildDMList(ThemeData theme) {
    final dms = [
      {
        "name": "Sarah Chen",
        "msg": "Hey, did you check the PR?",
        "time": "2m",
        "unread": 2,
        "online": true,
      },
      {
        "name": "Marcus Bold",
        "msg": "Let's sync at 4pm.",
        "time": "1h",
        "unread": 0,
        "online": false,
      },
      {
        "name": "Alex Rivera",
        "msg": "Thanks for the help!",
        "time": "Yesterday",
        "unread": 0,
        "online": true,
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: dms.length,
      separatorBuilder: (_, __) => const Divider(height: 24, thickness: 0.5),
      itemBuilder: (context, index) {
        final chat = dms[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Stack(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage(
                  "https://i.pravatar.cc/150?img=5",
                ),
              ),
              if (chat['online'] as bool)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            chat['name'] as String,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            chat['msg'] as String,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: (chat['unread'] as int) > 0
                  ? theme.colorScheme.onSurface
                  : Colors.grey,
              fontWeight: (chat['unread'] as int) > 0
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                chat['time'] as String,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              if ((chat['unread'] as int) > 0)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    chat['unread'].toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(
                title: chat['name'] as String,
                isChannel: false,
              ),
            ),
          ),
        );
      },
    );
  }

  // 2. Team Channels List (Square Icons like Slack)
  Widget _buildChannelList(ThemeData theme) {
    final channels = [
      {
        "name": "# general",
        "team": "Core Platform",
        "msg": "Dave: deployed to prod!",
        "time": "10m",
        "unread": 5,
      },
      {
        "name": "# design-systems",
        "team": "Mobile App",
        "msg": "New Figma file is up.",
        "time": "3h",
        "unread": 0,
      },
      {
        "name": "# random",
        "team": "Core Platform",
        "msg": "Lunch anyone?",
        "time": "5h",
        "unread": 0,
      },
    ];

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: channels.length,
      separatorBuilder: (_, __) => const Divider(height: 24, thickness: 0.5),
      itemBuilder: (context, index) {
        final channel = channels[index];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12), // Square for channels
            ),
            child: Icon(Icons.tag, color: theme.colorScheme.primary),
          ),
          title: Text(
            channel['name'] as String,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Row(
            children: [
              Text(
                channel['team'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "• ${channel['msg']}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          trailing: Text(
            channel['time'] as String,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(
                title: channel['name'] as String,
                subtitle: channel['team'] as String,
                isChannel: true,
              ),
            ),
          ),
        );
      },
    );
  }
}
