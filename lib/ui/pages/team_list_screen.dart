import 'package:code_mate/data/models/team_model.dart';
import 'package:code_mate/service/team_service.dart';
// These imports are now used again by the _TeamQuickMenu
import 'package:code_mate/ui/pages/invite_members_screen.dart';
import 'package:code_mate/ui/widgets/create_team_sheet.dart';
import 'package:flutter/material.dart';

import 'team_dashboard_screen.dart';
import 'team_settings_page.dart';

class TeamsListScreen extends StatefulWidget {
  const TeamsListScreen({super.key});

  @override
  State<TeamsListScreen> createState() => _TeamsListScreenState();
}

class _TeamsListScreenState extends State<TeamsListScreen> {
  late Future<List<TeamModel>> _teamsFuture;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  void _loadTeams() {
    setState(() {
      _teamsFuture = TeamService().getMyTeams();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Teams",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await showCreateTeamSheet(context);
              _loadTeams();
            },
            icon: const Icon(Icons.add_box_rounded),
            color: theme.colorScheme.primary,
          ),
        ],
      ),
      body: FutureBuilder<List<TeamModel>>(
        future: _teamsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Failed to load teams",
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  TextButton(onPressed: _loadTeams, child: const Text("Retry")),
                ],
              ),
            );
          }

          final myTeams = snapshot.data ?? [];
          if (myTeams.isEmpty) {
            return _buildEmptyState(theme);
          }

          return RefreshIndicator(
            onRefresh: () async => _loadTeams(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: myTeams.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _TeamTile(team: myTeams[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Text(
        "No teams found. Create one to start.",
        // Fixed the deprecated withOpacity warning
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _TeamTile extends StatelessWidget {
  final TeamModel team;
  const _TeamTile({required this.team});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          team.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${team.memberCount} members • ${team.visibility.name}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RoleBadge(role: team.userRole),
            _TeamQuickMenu(team: team),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeamDashboardScreen(team: team),
          ),
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final TeamRole role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    bool isHighLevel = role == TeamRole.owner || role == TeamRole.admin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighLevel
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.dividerTheme.color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        role.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isHighLevel
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _TeamQuickMenu extends StatelessWidget {
  final TeamModel team;
  const _TeamQuickMenu({required this.team});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'view':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamDashboardScreen(team: team),
              ),
            );
            break;
          case 'invite':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InviteMembersScreen(team: team),
              ),
            );
            break;
          case 'settings':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamSettingsScreen(team: team),
              ),
            );
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'view', child: Text("View Dashboard")),
        if (team.userRole != TeamRole.member)
          const PopupMenuItem(value: 'invite', child: Text("Invite Members")),
        if (team.userRole == TeamRole.owner)
          const PopupMenuItem(value: 'settings', child: Text("Settings")),
      ],
    );
  }
}
