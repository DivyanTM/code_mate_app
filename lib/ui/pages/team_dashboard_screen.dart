import 'package:flutter/material.dart';
import 'package:code_mate/data/models/team_model.dart';
import 'invite_members_screen.dart';

class TeamDashboardScreen extends StatelessWidget {
  final Team team;
  const TeamDashboardScreen({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isEmpty = team.memberCount <= 1;

    return Scaffold(
      appBar: AppBar(title: Text(team.name)),
      body: isEmpty ? _buildEmptyState(context, theme) : _buildDashboard(theme),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      // padding: const EdgeInsets.all(32),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_add_outlined,
              size: 64,
              color: theme.dividerTheme.color,
            ),
            const SizedBox(height: 16),
            const Text(
              "You're the owner",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "This team has no members yet. Invite people to get started.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InviteMembersScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text("Invite Members"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(ThemeData theme) {
    return const Center(child: Text("Active Team Feed / Projects"));
  }
}
