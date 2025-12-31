import 'package:code_mate/ui/pages/invite_members_screen.dart';
import 'package:flutter/material.dart';
import 'package:code_mate/data/models/team_model.dart';
import 'package:code_mate/ui/widgets/create_team_sheet.dart';
import 'team_dashboard_screen.dart';
import 'team_settings_page.dart';

class TeamsListScreen extends StatelessWidget {
  const TeamsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock Data
    final List<Team> myTeams = [
      Team(
        id: '1',
        name: "Core Platform",
        userRole: TeamRole.owner,
        memberCount: 1,
        visibility: TeamVisibility.private,
      ),
      Team(
        id: '2',
        name: "Mobile App",
        userRole: TeamRole.admin,
        memberCount: 12,
        visibility: TeamVisibility.public,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Teams",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => showCreateTeamSheet(context),
            icon: const Icon(Icons.add_box_rounded),
            color: theme.colorScheme.primary,
          ),
        ],
      ),
      body: myTeams.isEmpty
          ? _buildEmptyState(theme)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: myTeams.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _TeamTile(team: myTeams[index]),
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Text(
        "No teams found. Create one to start.",
        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),
      ),
    );
  }
}

class _TeamTile extends StatelessWidget {
  final Team team;
  const _TeamTile({required this.team});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            ? theme.colorScheme.primary.withOpacity(0.1)
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
  final Team team;
  const _TeamQuickMenu({required this.team});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      // THIS WAS MISSING: The logic to handle the click
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
            // Ensure you have this screen created or replace with your route
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InviteMembersScreen(),
              ),
            );
            break;
          case 'settings':
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamSettingsScreen(),
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
