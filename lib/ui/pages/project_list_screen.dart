import 'package:code_mate/ui/pages/project_dashboard_screen.dart';
import 'package:flutter/material.dart';
import '../../data/models/project_model.dart';
import 'project_settings_screen.dart';
import '../widgets/custom_input_field.dart';

class ProjectsListScreen extends StatelessWidget {
  const ProjectsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<Project> myProjects = [
      Project(
        id: '1',
        title: "CodeMate AI",
        techStack: ["Flutter", "Python"],
        status: ProjectStatus.active,
      ),
      Project(
        id: '2',
        title: "Internal API",
        techStack: ["Go", "gRPC"],
        status: ProjectStatus.planning,
      ),
    ];

    void _showCreateProjectSheet(BuildContext context) {
      final theme = Theme.of(context);
      final TextEditingController titleController = TextEditingController();
      final TextEditingController stackController = TextEditingController();
      String selectedStatus = 'Planning';

      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // Allows keyboard to push the sheet up
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => StatefulBuilder(
          // Needed to update status selection inside sheet
          builder: (context, setSheetState) => Padding(
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
                      "New Project",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Project Title
                CustomInputField(
                  controller: titleController,
                  label: "Project Title",
                  prefixIcon: Icons.rocket_launch_outlined,
                ),
                const SizedBox(height: 20),

                // Tech Stack
                CustomInputField(
                  controller: stackController,
                  label: "Tech Stack (e.g. Flutter, Firebase)",
                  prefixIcon: Icons.code_rounded,
                ),
                const SizedBox(height: 24),

                // Status Selector
                Text(
                  "Initial Status",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['Planning', 'Active', 'On Hold'].map((status) {
                    final isSelected = selectedStatus == status;
                    return ChoiceChip(
                      label: Text(status),
                      selected: isSelected,
                      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                      onSelected: (val) =>
                          setSheetState(() => selectedStatus = status),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement Save Logic
                      final title = titleController.text.trim();
                      if (title.isNotEmpty) {
                        Navigator.pop(context);
                        // Usually you'd navigate to ProjectDashboard here
                      }
                    },
                    child: const Text("Create Project"),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Projects",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => _showCreateProjectSheet(context),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: myProjects.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final project = myProjects[index];
          return Card(
            child: ListTile(
              title: Text(
                project.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(project.techStack.join(" • ")),
              trailing: _StatusChip(status: project.status),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProjectDashboardScreen(project: project),
                ),
              ),
              onLongPress: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProjectSettingsScreen(project: project),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ProjectStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
}
