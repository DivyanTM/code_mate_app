import 'package:code_mate/service/project_service.dart';
import 'package:flutter/material.dart';

import '../../data/models/project_model.dart';
import '../widgets/custom_input_field.dart';
import 'project_dashboard_screen.dart';
import 'project_settings_screen.dart';

class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  late Future<List<Project>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  void _loadProjects() {
    setState(() {
      _projectsFuture = ProjectService().getMyProjects();
    });
  }

  Future<void> _showCreateProjectSheet(BuildContext context) async {
    final theme = Theme.of(context);
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    bool isCreating = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
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

              CustomInputField(
                controller: titleController,
                label: "Project Title",
                prefixIcon: Icons.rocket_launch_outlined,
              ),
              const SizedBox(height: 20),

              CustomInputField(
                controller: descController,
                label: "Description (Optional)",
                prefixIcon: Icons.description_outlined,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isCreating
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Project Title is required'),
                              ),
                            );
                            return;
                          }

                          setSheetState(() => isCreating = true);

                          final (success, message) = await ProjectService()
                              .createProject(
                                title: title,
                                description: descController.text.trim(),
                              );

                          if (!context.mounted) return;
                          setSheetState(() => isCreating = false);

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));

                          if (success) {
                            Navigator.pop(context);
                          }
                        },
                  child: isCreating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Create Project"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Projects",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await _showCreateProjectSheet(context);
              _loadProjects(); // Refresh the list after the sheet closes
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: FutureBuilder<List<Project>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Failed to load projects",
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  TextButton(
                    onPressed: _loadProjects,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            );
          }

          final myProjects = snapshot.data ?? [];

          if (myProjects.isEmpty) {
            return Center(
              child: Text(
                "No projects found. Create one to start.",
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadProjects(),
            child: ListView.separated(
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
                    subtitle: Text(
                      project.description ?? "No description provided",
                    ),
                    trailing: _StatusChip(status: project.status),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProjectDashboardScreen(project: project),
                      ),
                    ).then((_) => _loadProjects()),
                    onLongPress: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProjectSettingsScreen(project: project),
                      ),
                    ).then((_) => _loadProjects()),
                  ),
                );
              },
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

    // Changing color based on status
    final color = status == ProjectStatus.active
        ? theme.colorScheme.primary
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
