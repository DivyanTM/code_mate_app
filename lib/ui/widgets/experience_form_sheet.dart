import 'package:flutter/material.dart';
import 'custom_input_field.dart';

class ExperienceFormSheet extends StatefulWidget {
  final Map<String, String>? initialData; // If null, it's "Add New"

  const ExperienceFormSheet({super.key, this.initialData});

  @override
  State<ExperienceFormSheet> createState() => _ExperienceFormSheetState();
}

class _ExperienceFormSheetState extends State<ExperienceFormSheet> {
  late TextEditingController _roleController;
  late TextEditingController _companyController;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _roleController = TextEditingController(
      text: widget.initialData?['role'] ?? '',
    );
    _companyController = TextEditingController(
      text: widget.initialData?['company'] ?? '',
    );
    _durationController = TextEditingController(
      text: widget.initialData?['date'] ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initialData != null;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? "Edit Experience" : "Add Experience",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),

          CustomInputField(
            label: "Role / Title",
            prefixIcon: Icons.work_outline,
            controller: _roleController,
          ),
          const SizedBox(height: 16),
          CustomInputField(
            label: "Company Name",
            prefixIcon: Icons.business_outlined,
            controller: _companyController,
          ),
          const SizedBox(height: 16),
          CustomInputField(
            label: "Duration (e.g. 2021 - Present)",
            prefixIcon: Icons.calendar_today_outlined,
            controller: _durationController,
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Return the data to the parent screen
                Navigator.pop(context, {
                  'role': _roleController.text,
                  'company': _companyController.text,
                  'date': _durationController.text,
                  'color': Colors.blue, // Default color for timeline
                });
              },
              child: Text(isEditing ? "Save Changes" : "Add Position"),
            ),
          ),
          if (isEditing) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {
                  // Return 'delete' signal
                  Navigator.pop(context, {'delete': true});
                },
                child: Text(
                  "Remove this position",
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
