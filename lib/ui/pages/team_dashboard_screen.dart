import 'package:code_mate/data/models/team_member.dart';
import 'package:code_mate/data/models/team_model.dart';
import 'package:code_mate/service/team_service.dart';
import 'package:flutter/material.dart';

import 'invite_members_screen.dart';

class TeamDashboardScreen extends StatefulWidget {
  final TeamModel team;
  const TeamDashboardScreen({super.key, required this.team});

  @override
  State<TeamDashboardScreen> createState() => _TeamDashboardScreenState();
}

class _TeamDashboardScreenState extends State<TeamDashboardScreen> {
  List<TeamMemberModel> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    setState(() => _isLoading = true);
    final members = await TeamService().getTeamMembers(widget.team.id);
    if (mounted) {
      setState(() {
        _members = members;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleUpdateRole(TeamMemberModel member, String newRole) async {
    if (member.role == 'owner') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot change the role of the team owner'),
        ),
      );
      return;
    }

    final (success, message) = await TeamService().updateMemberRole(
      widget.team.id,
      member.userId,
      newRole,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    if (success) _fetchMembers(); // Refresh list on success
  }

  Future<void> _handleRemoveMember(TeamMemberModel member) async {
    if (member.role == 'owner') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot remove the team owner')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member?'),
        content: Text(
          'Are you sure you want to remove ${member.username} from the team?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final (success, message) = await TeamService().removeTeamMember(
      widget.team.id,
      member.userId,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    if (success) _fetchMembers(); // Refresh list on success
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Using the fetched list length instead of the static team.memberCount
    final bool isEmpty = !_isLoading && _members.length <= 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.team.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InviteMembersScreen(team: widget.team),
                ),
              );
              _fetchMembers(); // Refresh list after returning from invite screen
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : isEmpty
          ? _buildEmptyState(context, theme)
          : _buildDashboard(theme),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
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
              "This team has no members yet. Add people to get started.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InviteMembersScreen(team: widget.team),
                  ),
                );
                _fetchMembers(); // Refresh after returning
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Members"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          child: Text(
            "Team Members (${_members.length})",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchMembers,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _members.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final member = _members[index];

                // Determine if the current app user has permission to edit this member
                // For safety, we only show edit options if the current user is an Admin/Owner
                final bool isCurrentUserHighRole =
                    widget.team.userRole == TeamRole.owner ||
                    widget.team.userRole == TeamRole.admin;

                // You cannot edit the owner, period.
                final bool canEdit =
                    isCurrentUserHighRole && member.role != 'owner';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      member.username[0].toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    member.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    member.email,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _RoleBadge(roleString: member.role, theme: theme),
                      if (canEdit)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (value) {
                            if (value == 'remove') {
                              _handleRemoveMember(member);
                            } else {
                              _handleUpdateRole(member, value);
                            }
                          },
                          itemBuilder: (context) => [
                            if (member.role != 'admin')
                              const PopupMenuItem(
                                value: 'admin',
                                child: Text("Make Admin"),
                              ),
                            if (member.role != 'developer')
                              const PopupMenuItem(
                                value: 'developer',
                                child: Text("Make Developer"),
                              ),
                            const PopupMenuDivider(),
                            const PopupMenuItem(
                              value: 'remove',
                              child: Text(
                                "Remove from team",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Helper widget for displaying the role pill
class _RoleBadge extends StatelessWidget {
  final String roleString;
  final ThemeData theme;

  const _RoleBadge({required this.roleString, required this.theme});

  @override
  Widget build(BuildContext context) {
    bool isHighLevel = roleString == 'owner' || roleString == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighLevel
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.dividerTheme.color?.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        roleString.toUpperCase(),
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
