import 'package:flutter/material.dart';
import 'package:code_mate/data/models/project_model.dart';
import 'package:code_mate/service/project_service.dart';
import 'project_settings_screen.dart';

class ProjectDashboardScreen extends StatefulWidget {
  final Project project;
  const ProjectDashboardScreen({super.key, required this.project});

  @override
  State<ProjectDashboardScreen> createState() => _ProjectDashboardScreenState();
}

class _ProjectDashboardScreenState extends State<ProjectDashboardScreen> {
  List<dynamic> _members = [];
  List<String> _skills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      ProjectService().getProjectMembers(widget.project.id),
      ProjectService().getProjectSkills(widget.project.id),
    ]);

    if (mounted) {
      setState(() {
        _members = results[0] as List<dynamic>;
        _skills = results[1] as List<String>;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectSettingsScreen(project: widget.project),
              ),
            ).then((_) => _fetchData()),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 32),
                    _buildSectionHeader(theme, "TEAM"),
                    _buildMembersList(theme),
                    const SizedBox(height: 32),
                    _buildSectionHeader(theme, "ROADMAP"),
                    _buildRoadmapMock(theme),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildStatusChip(theme),
            const SizedBox(width: 12),
            Text(
              widget.project.description ?? "No description",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          // Fixed the .join() issue by mapping the fetched skills directly
          children: _skills
              .map(
                (s) => Chip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  backgroundColor: theme.colorScheme.surface,
                  side: BorderSide(
                    color: theme.dividerTheme.color ?? Colors.grey.shade300,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    // Replaced deprecated withOpacity
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        widget.project.status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildMembersList(ThemeData theme) {
    if (_members.isEmpty) {
      return Text(
        "No members assigned.",
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ), // Replaced withOpacity
      );
    }
    return Column(
      children: _members
          .map(
            (m) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person, size: 20)),
              title: Text(m['userId']?['username'] ?? "Unknown"),
              subtitle: Text(m['role'] ?? "developer"),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: theme.colorScheme.onSurface.withValues(
            alpha: 0.6,
          ), // Replaced withOpacity
        ),
      ),
    );
  }

  Widget _buildRoadmapMock(ThemeData theme) {
    return Text(
      "Roadmap tracking coming soon...",
      style: TextStyle(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ), // Replaced withOpacity
    );
  }
}
