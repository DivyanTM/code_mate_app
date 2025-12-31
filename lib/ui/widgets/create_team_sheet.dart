import 'package:flutter/material.dart';
import '../widgets/custom_input_field.dart'; 

void showCreateTeamSheet(BuildContext context) {
  final theme = Theme.of(context);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (context) => _CreateTeamForm(),
  );
}

class _CreateTeamForm extends StatefulWidget {
  @override
  State<_CreateTeamForm> createState() => _CreateTeamFormState();
}

class _CreateTeamFormState extends State<_CreateTeamForm> {
  String _visibility = 'Private';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24, right: 24, top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("New Team", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const CustomInputField(label: "Team Name", prefixIcon: Icons.groups_outlined),
          const SizedBox(height: 24),
          Text("Visibility", style: const TextStyle(fontWeight: FontWeight.bold)),
          ...['Private', 'Invite Only', 'Public'].map((type) => RadioListTile(
            title: Text(type),
            value: type,
            groupValue: _visibility,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) => setState(() => _visibility = val!),
          )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context), // Logic to save & redirect
              child: const Text("Create Team"),
            ),
          ),
        ],
      ),
    );
  }
}