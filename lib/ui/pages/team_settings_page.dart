import 'package:flutter/material.dart';
import '../widgets/custom_input_field.dart';

class TeamSettingsScreen extends StatefulWidget {
  const TeamSettingsScreen({super.key});

  @override
  State<TeamSettingsScreen> createState() => _TeamSettingsScreenState();
}

class _TeamSettingsScreenState extends State<TeamSettingsScreen> {
  String selectedProject = "None Selected";
  String preferredLanguage = "English";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Team Settings"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Save", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(theme, "GENERAL INFO"),
            const CustomInputField(label: "Team Name", prefixIcon: Icons.groups_rounded),
            const SizedBox(height: 20),
            const CustomInputField(label: "Description", prefixIcon: Icons.description_outlined),
            
            const SizedBox(height: 32),
            _buildSectionHeader(theme, "PROJECT ASSIGNMENT"),
            
            // PROJECT PICKER (SELECT INSTEAD OF INPUT)
            _buildSelectionTile(
              theme,
              label: "Linked Project",
              value: selectedProject,
              icon: Icons.assignment_outlined,
              onTap: () => _showProjectPicker(context),
            ),

            const SizedBox(height: 32),
            _buildSectionHeader(theme, "REQUIREMENTS & STACK"),
            const CustomInputField(label: "Required Skills (Comma separated)", prefixIcon: Icons.bolt_rounded),
            const SizedBox(height: 20),
            
            // PREFERRED LANGUAGE PICKER
            _buildSelectionTile(
              theme,
              label: "Preferred Language",
              value: preferredLanguage,
              icon: Icons.language_rounded,
              onTap: () => _showLanguagePicker(context),
            ),

            const SizedBox(height: 40),
            _buildSectionHeader(theme, "DANGER ZONE"),
            _buildDangerAction(theme, title: "Delete Team", icon: Icons.delete_forever, onTap: () {}),
          ],
        ),
      ),
    );
  }

  // REUSABLE SELECTION TILE
  Widget _buildSelectionTile(ThemeData theme, {
    required String label, 
    required String value, 
    required IconData icon, 
    required VoidCallback onTap
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.7))),
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
                Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // BOTTOM SHEET PICKER FOR PROJECTS
  void _showProjectPicker(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Project", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: Colors.blue),
              title: const Text("Create New Project"),
              onTap: () { /* Navigate to Project Creation */ },
            ),
            const Divider(),
            // Mock list of existing projects
            ...['E-Commerce App', 'AI Chatbot', 'Portfolio Site'].map((proj) => ListTile(
              title: Text(proj),
              trailing: selectedProject == proj ? Icon(Icons.check_circle, color: theme.colorScheme.primary) : null,
              onTap: () {
                setState(() => selectedProject = proj);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  // SIMPLE PICKER FOR LANGUAGE
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
            children: languages.map((lang) => RadioListTile(
              title: Text(lang),
              value: lang,
              groupValue: preferredLanguage,
              onChanged: (val) {
                setState(() => preferredLanguage = val!);
                Navigator.pop(context);
              },
            )).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1.1)),
    );
  }

  Widget _buildDangerAction(ThemeData theme, {required String title, required IconData icon, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: theme.colorScheme.error),
      title: Text(title, style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
      shape: RoundedRectangleBorder(side: BorderSide(color: theme.colorScheme.error.withOpacity(0.2)), borderRadius: BorderRadius.circular(12)),
    );
  }
}