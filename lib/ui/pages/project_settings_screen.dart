import 'package:flutter/material.dart';
import '../../data/models/project_model.dart';
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

  // State for Pickers
  late ProjectStatus _status;
  String _linkedTeamName = "Unassigned"; // In real app, fetch name via ID

  @override
  void initState() {
    super.initState();
    // Pre-fill data from the passed Project object
    _titleController = TextEditingController(text: widget.project.title);
    _descController = TextEditingController(
      text: widget.project.description ?? "",
    );
    _stackController = TextEditingController(
      text: widget.project.techStack.join(", "),
    );
    _status = widget.project.status;

    // Simulating looking up the team name if an ID exists
    if (widget.project.linkedTeamId != null) {
      _linkedTeamName = "Core Platform Team";
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _stackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Edit Project"),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: Text(
              "Save",
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
              onTap: () {},
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
              border: Border.all(color: theme.dividerTheme.color!),
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
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
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
          border: Border.all(color: color.withOpacity(0.3)),
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

  // --- LOGIC METHODS ---

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
    // Reusing the same logic from Dashboard/Creation
    showModalBottomSheet(
      context: context,
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
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text("Core Platform Team"),
              onTap: () {
                setState(() => _linkedTeamName = "Core Platform Team");
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_outlined),
              title: const Text("No Team (Unassigned)"),
              onTap: () {
                setState(() => _linkedTeamName = "Unassigned");
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() {
    // TODO: Call your Provider/Bloc to update the project in the backend
    final updatedTitle = _titleController.text;
    final updatedStack = _stackController.text
        .split(',')
        .map((e) => e.trim())
        .toList();

    print("Saving: $updatedTitle, Status: $_status, Stack: $updatedStack");
    Navigator.pop(context); // Go back to Dashboard
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
              // Perform delete logic
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close Settings page
              Navigator.pop(context); // Close Dashboard (return to list)
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
