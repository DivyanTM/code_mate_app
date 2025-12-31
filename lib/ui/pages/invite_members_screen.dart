import 'package:flutter/material.dart';
import '../widgets/custom_input_field.dart';

class InviteMembersScreen extends StatelessWidget {
  const InviteMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Invite Members")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CustomInputField(label: "Username or Email", prefixIcon: Icons.search),
            const SizedBox(height: 24),
            DropdownButtonFormField(
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              value: 'Member',
              items: ['Member', 'Admin'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (val) {},
            ),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {}, child: const Text("Send Invite"))),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 20),
            _buildInviteLinkTile(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteLinkTile(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Shareable Link", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Expires in 30 days", style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.copy_rounded, size: 20)),
        ],
      ),
    );
  }
}