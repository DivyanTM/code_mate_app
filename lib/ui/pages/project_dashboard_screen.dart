import 'package:code_mate/ui/pages/project_settings_screen.dart';
import 'package:flutter/material.dart';
import '../../data/models/project_model.dart';

class ProjectDashboardScreen extends StatefulWidget {
  final Project project;

  const ProjectDashboardScreen({super.key, required this.project});

  @override
  State<ProjectDashboardScreen> createState() => _ProjectDashboardScreenState();
}

class _ProjectDashboardScreenState extends State<ProjectDashboardScreen> {
  // Logic to handle internal state if a team gets assigned
  late bool hasTeam;

  @override
  void initState() {
    super.initState();
    hasTeam = widget.project.linkedTeamId != null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.project.title),
        // inside ProjectDashboardScreen
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // WIRING ADDED HERE:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProjectSettingsScreen(project: widget.project),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProjectHeader(theme),
            const SizedBox(height: 32),

            _buildSectionHeader(theme, "TEAM COLLABORATION"),
            const SizedBox(height: 16),
            hasTeam ? _buildTeamOverview(theme) : _buildMissingTeamCTA(theme),

            const SizedBox(height: 32),
            _buildSectionHeader(theme, "PROJECT ROADMAP"),
            const SizedBox(height: 12),
            _buildRoadmapList(theme),
          ],
        ),
      ),
    );
  }

  // --- PRIVATE UI METHODS ---

  Widget _buildProjectHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildStatusChip(theme, widget.project.status),
            const SizedBox(width: 8),
            Text(
              "Created Feb 2026",
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.project.techStack
              .map(
                (tech) => Chip(
                  label: Text(tech, style: const TextStyle(fontSize: 12)),
                  backgroundColor: theme.colorScheme.surface,
                  side: BorderSide(color: theme.dividerTheme.color!),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildStatusChip(ThemeData theme, ProjectStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w900,
        color: theme.colorScheme.onSurface.withOpacity(0.6),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildMissingTeamCTA(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerTheme.color!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.group_off_rounded,
            size: 48,
            color: theme.dividerTheme.color,
          ),
          const SizedBox(height: 16),
          const Text(
            "No Team Assigned",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Link a team to assign tasks and start coding.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showTeamPicker(context),
            icon: const Icon(Icons.link_rounded, size: 18),
            label: const Text("Assign Team"),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamOverview(ThemeData theme) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.groups)),
        title: const Text("Core Platform Team"),
        subtitle: const Text("5 active members"),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to the Team details
        },
      ),
    );
  }

  Widget _buildRoadmapList(ThemeData theme) {
    final tasks = [
      {"title": "Architecture Setup", "done": true},
      {"title": "Database Schema Design", "done": true},
      {"title": "API Auth Module", "done": false},
      {"title": "Frontend Integration", "done": false},
    ];

    return Column(
      children: tasks
          .map(
            (task) => CheckboxListTile(
              value: task['done'] as bool,
              onChanged: (val) {},
              title: Text(
                task['title'] as String,
                style: TextStyle(
                  decoration: (task['done'] as bool)
                      ? TextDecoration.lineThrough
                      : null,
                  color: (task['done'] as bool) ? Colors.grey : null,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          )
          .toList(),
    );
  }

  // --- INTERACTIVE METHODS ---

  void _showTeamPicker(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Assign a Team",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Mock list of user's teams
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text("Core Platform Team"),
              onTap: () {
                setState(() => hasTeam = true);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("Create New Team"),
              onTap: () {
                // Logic to navigate to Team Creation
              },
            ),
          ],
        ),
      ),
    );
  }
}
