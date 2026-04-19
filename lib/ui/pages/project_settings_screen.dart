import 'package:code_mate/data/models/project_model.dart';
import 'package:code_mate/data/models/team_model.dart';
import 'package:code_mate/service/project_service.dart';
import 'package:code_mate/service/team_service.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_input_field.dart';

class ProjectSettingsScreen extends StatefulWidget {
  final Project project;

  const ProjectSettingsScreen({super.key, required this.project});

  @override
  State<ProjectSettingsScreen> createState() => _ProjectSettingsScreenState();
}

class _ProjectSettingsScreenState extends State<ProjectSettingsScreen> {
  // Controllers for editing text
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _stackController;

  String? _selectedTeamId;

  // State for Pickers
  late ProjectStatus _status;
  String _linkedTeamName = "Unassigned";

  // Loading states for UI
  bool _isLoadingData = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill data from the passed Project object
    _titleController = TextEditingController(text: widget.project.title);
    _descController = TextEditingController(
      text: widget.project.description ?? "",
    );
    _stackController = TextEditingController();
    _status = widget.project.status;

    // 1. THE MISSING LINK: Actually assign the ID from the project model!
    _selectedTeamId = widget.project.linkedTeamId;

    // 2. Set an initial loading state if a team is attached
    if (_selectedTeamId != null && _selectedTeamId!.isNotEmpty) {
      _linkedTeamName = "Loading Team...";
    } else {
      _linkedTeamName = "Unassigned";
    }

    _fetchExistingSkills();

    // 3. Call the method to fetch the real team name
    _resolveTeamName();
  }

  // 4. ADD THIS METHOD: It fetches your teams and finds the name matching the ID
  Future<void> _resolveTeamName() async {
    if (_selectedTeamId != null && _selectedTeamId!.isNotEmpty) {
      try {
        final teams = await TeamService().getMyTeams();
        final matchedTeam = teams.firstWhere(
          (t) => t.id == _selectedTeamId,
          // Provide a fallback so it doesn't crash if the team was deleted
          orElse: () => TeamModel(
            id: '',
            name: 'Team Attached',
            userRole: TeamRole.developer,
            memberCount: 0,
            visibility: TeamVisibility.private,
          ),
        );

        if (mounted) {
          setState(() {
            _linkedTeamName = matchedTeam.name;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _linkedTeamName = "Team Attached");
      }
    }
  }

  // Fetch the real skills from the backend mapping table
  Future<void> _fetchExistingSkills() async {
    final skills = await ProjectService().getProjectSkills(widget.project.id);
    if (mounted) {
      setState(() {
        _stackController.text = skills.join(", ");
        _isLoadingData = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _stackController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project Name cannot be empty')),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Convert comma-separated string to a clean List<String>
    final List<String> techStack = _stackController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Call the actual backend service
    final (success, message) = await ProjectService().updateProject(
      projectId: widget.project.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      status: _status.name,
      skills: techStack,
      teamId: _selectedTeamId ?? "",
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    if (success) {
      Navigator.pop(context, true); // Return true to trigger dashboard refresh
    }
  }

  Future<void> _handleDelete() async {
    final (success, message) = await ProjectService().deleteProject(
      widget.project.id,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    if (success) {
      // Close dialog, close settings, close dashboard -> back to list
      Navigator.of(context)
        ..pop()
        ..pop()
        ..pop();
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Project?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _handleDelete(); // Trigger actual API delete
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Edit Project"),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _isLoadingData ? null : _saveChanges,
              child: Text(
                "Save",
                style: TextStyle(
                  color: _isLoadingData
                      ? Colors.grey
                      : theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(theme, "GENERAL DETAILS"),
                  CustomInputField(
                    label: "Project Name",
                    prefixIcon: Icons.rocket_launch_outlined,
                    controller: _titleController,
                  ),
                  const SizedBox(height: 20),
                  CustomInputField(
                    label: "Description",
                    prefixIcon: Icons.notes_rounded,
                    controller: _descController,
                  ),

                  const SizedBox(height: 32),
                  _buildSectionHeader(theme, "STATUS & TEAM"),

                  // 1. Status Picker
                  _buildSelectionTile(
                    theme,
                    label: "Current Status",
                    value: _status.name.toUpperCase(),
                    icon: Icons.flag_outlined,
                    onTap: () => _showStatusPicker(context),
                  ),
                  const SizedBox(height: 16),

                  // 2. Team Picker
                  _buildSelectionTile(
                    theme,
                    label: "Assigned Team",
                    value: _linkedTeamName,
                    icon: Icons.group_work_outlined,
                    onTap: () => _showTeamPicker(context),
                  ),

                  const SizedBox(height: 32),
                  _buildSectionHeader(theme, "TECHNICAL"),
                  CustomInputField(
                    label: "Tech Stack (Comma separated)",
                    prefixIcon: Icons.code,
                    controller: _stackController,
                  ),

                  const SizedBox(height: 48),
                  _buildSectionHeader(theme, "DANGER ZONE"),
                  _buildDangerAction(
                    theme,
                    title: "Archive Project",
                    icon: Icons.archive_outlined,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Archive coming soon!')),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDangerAction(
                    theme,
                    title: "Delete Project",
                    icon: Icons.delete_forever_rounded,
                    isCritical: true,
                    onTap: () => _confirmDelete(context),
                  ),
                ],
              ),
            ),
    );
  }

  // --- UI HELPERS ---

  Widget _buildSelectionTile(
    ThemeData theme, {
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.dividerTheme.color ?? Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 12),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDangerAction(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    bool isCritical = false,
  }) {
    final color = isCritical
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ProjectStatus.values
              .map(
                (status) => ListTile(
                  title: Text(status.name.toUpperCase()),
                  trailing: _status == status
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    setState(() => _status = status);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showTeamPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Team",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),

            // Option to unassign a team
            ListTile(
              leading: const Icon(Icons.group_off_outlined),
              title: const Text("No Team (Unassigned)"),
              trailing: (_selectedTeamId == null || _selectedTeamId!.isEmpty)
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () {
                setState(() {
                  _selectedTeamId = "";
                  _linkedTeamName = "Unassigned";
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),

            // Fetch and list the user's real teams
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: FutureBuilder<List<TeamModel>>(
                future: TeamService().getMyTeams(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || (snapshot.data ?? []).isEmpty) {
                    return const Center(
                      child: Text("No teams available. Create one first!"),
                    );
                  }

                  final teams = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: teams.length,
                    itemBuilder: (context, index) {
                      final team = teams[index];
                      final isSelected = _selectedTeamId == team.id;

                      return ListTile(
                        leading: const Icon(Icons.group),
                        title: Text(team.name),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: Colors.blue)
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedTeamId = team.id;
                            _linkedTeamName = team.name;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
