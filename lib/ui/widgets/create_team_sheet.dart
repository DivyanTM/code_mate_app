import 'package:flutter/material.dart';
import 'package:code_mate/service/team_service.dart';
import '../widgets/custom_input_field.dart';

// 1. Changed to return Future<void> so we can await it
Future<void> showCreateTeamSheet(BuildContext context) {
  final theme = Theme.of(context);
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => const _CreateTeamForm(),
  );
}

class _CreateTeamForm extends StatefulWidget {
  const _CreateTeamForm({super.key});

  @override
  State<_CreateTeamForm> createState() => _CreateTeamFormState();
}

class _CreateTeamFormState extends State<_CreateTeamForm> {
  // 2. Added controllers and loading state
  final TextEditingController _nameController = TextEditingController();
  String _visibility = 'Private';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 3. The logic to handle the API call
  Future<void> _handleCreate() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Team name is required')));
      return;
    }

    setState(() => _isLoading = true);

    // Map UI labels to backend enums
    final String backendVisibility = _visibility == 'Public'
        ? 'public'
        : 'private';

    final (success, message) = await TeamService().createTeam(
      name: name,
      visibility: backendVisibility,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    if (success) {
      Navigator.pop(context); // Close sheet on success
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "New Team",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Attached the controller
          CustomInputField(
            controller: _nameController,
            label: "Team Name",
            prefixIcon: Icons.groups_outlined,
          ),
          const SizedBox(height: 24),

          const Text(
            "Visibility",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...['Private', 'Invite Only', 'Public'].map(
            (type) => RadioListTile(
              title: Text(type),
              value: type,
              groupValue: _visibility,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) => setState(() => _visibility = val.toString()),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // Trigger the network call
              onPressed: _isLoading ? null : _handleCreate,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Create Team"),
            ),
          ),
        ],
      ),
    );
  }
}
