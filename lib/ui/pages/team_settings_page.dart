import 'package:code_mate/data/models/team_model.dart';
import 'package:code_mate/service/team_service.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_input_field.dart';

class TeamSettingsScreen extends StatefulWidget {
  final TeamModel team;

  const TeamSettingsScreen({super.key, required this.team});

  @override
  State<TeamSettingsScreen> createState() => _TeamSettingsScreenState();
}

class _TeamSettingsScreenState extends State<TeamSettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _skillsController;

  String selectedProject = "None Selected";
  String preferredLanguage = "English";

  bool _isLoading = false; // For the Save button
  bool _isPageLoading = true; // For the initial data fetch

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.team.name);
    _descController = TextEditingController(
      text: widget.team.description ?? '',
    );
    _skillsController = TextEditingController();

    // Trigger the API fetch as soon as the screen loads
    _fetchTeamData();
  }

  Future<void> _fetchTeamData() async {
    // Fetch the skills from the API
    final skills = await TeamService().getTeamSkills(widget.team.id);

    if (mounted) {
      setState(() {
        // Join the list into a comma-separated string for the text field
        _skillsController.text = skills.join(', ');
        _isPageLoading = false; // Hide the loading spinner
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team Name cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final rawSkills = _skillsController.text;
    List<String> skillsList = [];
    if (rawSkills.isNotEmpty) {
      skillsList = rawSkills
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    final (success, message) = await TeamService().updateTeam(
      teamId: widget.team.id,
      name: name,
      description: desc,
      skills: skillsList,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    if (success) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Team?'),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Delete functionality is currently disabled."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Team Settings"),
        actions: [
          if (_isLoading)
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
              onPressed: _isPageLoading ? null : _handleSave,
              child: Text(
                "Save",
                style: TextStyle(
                  color: _isPageLoading
                      ? Colors.grey
                      : theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      // Switch between the loading spinner and the form
      body: _isPageLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(theme, "GENERAL INFO"),
                  CustomInputField(
                    controller: _nameController,
                    label: "Team Name",
                    prefixIcon: Icons.groups_rounded,
                  ),
                  const SizedBox(height: 20),
                  CustomInputField(
                    controller: _descController,
                    label: "Description",
                    prefixIcon: Icons.description_outlined,
                  ),

                  const SizedBox(height: 32),
                  _buildSectionHeader(theme, "PROJECT ASSIGNMENT"),

                  _buildSelectionTile(
                    theme,
                    label: "Linked Project",
                    value: selectedProject,
                    icon: Icons.assignment_outlined,
                    onTap: () => _showProjectPicker(context),
                  ),

                  const SizedBox(height: 32),
                  _buildSectionHeader(theme, "REQUIREMENTS & STACK"),
                  CustomInputField(
                    controller: _skillsController,
                    label: "Required Skills (Comma separated)",
                    prefixIcon: Icons.bolt_rounded,
                  ),
                  const SizedBox(height: 20),

                  _buildSelectionTile(
                    theme,
                    label: "Preferred Language",
                    value: preferredLanguage,
                    icon: Icons.language_rounded,
                    onTap: () => _showLanguagePicker(context),
                  ),

                  const SizedBox(height: 40),
                  _buildSectionHeader(theme, "DANGER ZONE"),
                  _buildDangerAction(
                    theme,
                    title: "Delete Team",
                    icon: Icons.delete_forever,
                    onTap: _isLoading ? () {} : _handleDelete,
                  ),
                ],
              ),
            ),
    );
  }

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
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showProjectPicker(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Select Project",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: Colors.blue),
              title: const Text("Create New Project"),
              onTap: () {
                /* Navigate to Project Creation */
              },
            ),
            const Divider(),
            ...['E-Commerce App', 'AI Chatbot', 'Portfolio Site'].map(
              (proj) => ListTile(
                title: Text(proj),
                trailing: selectedProject == proj
                    ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                    : null,
                onTap: () {
                  setState(() => selectedProject = proj);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final languages = ['English', 'Spanish', 'Mandarin', 'Hindi', 'German'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Preferred Language"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: languages
                .map(
                  (lang) => RadioListTile(
                    title: Text(lang),
                    value: lang,
                    groupValue: preferredLanguage,
                    onChanged: (val) {
                      setState(() => preferredLanguage = val!);
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildDangerAction(
    ThemeData theme, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: theme.colorScheme.error),
      title: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.error,
          fontWeight: FontWeight.bold,
        ),
      ),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
