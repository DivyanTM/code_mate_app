import 'package:flutter/material.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/experience_form_sheet.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // --- CONTROLLERS ---
  final _nameController = TextEditingController(text: "Alex Rivera");
  final _roleController = TextEditingController(text: "Senior Backend Architect");
  final _bioController = TextEditingController(text: "Building scalable distributed systems. Open source enthusiast.");
  final _locationController = TextEditingController(text: "San Francisco, CA");
  final _githubController = TextEditingController(text: "github.com/alexrivera");
  final _linkedinController = TextEditingController(text: "linkedin.com/in/alex");
  
  // Skill Input Controller
  final _skillInputController = TextEditingController();

  // --- STATE DATA ---
  
  // Skills List
  final List<String> _skills = ["Flutter", "Go", "AWS", "Kubernetes", "gRPC"];

  // Experience List
  final List<Map<String, dynamic>> _experience = [
    {
      "role": "Senior Backend Architect",
      "company": "TechFlow Systems",
      "date": "2021 - Present",
      "color": Colors.blue,
    },
    {
      "role": "Lead Developer",
      "company": "StartupX",
      "date": "2018 - 2021",
      "color": Colors.orange,
    },
    {
      "role": "Software Engineer",
      "company": "DevCorp",
      "date": "2016 - 2018",
      "color": Colors.purple,
    },
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              "Save", 
              style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. PROFILE PHOTO EDIT
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: const NetworkImage("https://i.pravatar.cc/300?img=11"),
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  ),
                  Positioned(
                    bottom: 0, 
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        // Logic to pick image from gallery would go here
                        print("Pick Image");
                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.colorScheme.primary,
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 2. BASIC INFO SECTION
            _buildSectionLabel(theme, "BASIC INFO"),
            CustomInputField(
              label: "Full Name", 
              prefixIcon: Icons.person_outline, 
              controller: _nameController
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: "Headline / Role", 
              prefixIcon: Icons.work_outline, 
              controller: _roleController
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: "Bio", 
              prefixIcon: Icons.info_outline, 
              controller: _bioController
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: "Location", 
              prefixIcon: Icons.location_on_outlined, 
              controller: _locationController
            ),
            
            const SizedBox(height: 40),

            // 3. EXPERIENCE SECTION (Interactive List)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionLabel(theme, "EXPERIENCE"),
                IconButton(
                  onPressed: () => _openExperienceSheet(context),
                  icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
                  tooltip: "Add Position",
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _experience.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _experience[index];
                return _buildEditableExperienceCard(theme, item, index);
              },
            ),

            const SizedBox(height: 40),

            // 4. SKILLS SECTION
            _buildSectionLabel(theme, "SKILLS & TECH"),
            Row(
              children: [
                Expanded(
                  child: CustomInputField(
                    label: "Add Skill", 
                    prefixIcon: Icons.bolt, 
                    controller: _skillInputController
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filled(
                  onPressed: _addSkill,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8, 
              runSpacing: 8,
              children: _skills.map((skill) => Chip(
                label: Text(skill),
                backgroundColor: theme.colorScheme.surface,
                deleteIcon: const Icon(Icons.close, size: 14),
                onDeleted: () => setState(() => _skills.remove(skill)),
                side: BorderSide(color: theme.dividerTheme.color!),
              )).toList(),
            ),

            const SizedBox(height: 40),

            // 5. SOCIAL LINKS
            _buildSectionLabel(theme, "SOCIAL LINKS"),
            CustomInputField(
              label: "GitHub URL", 
              prefixIcon: Icons.code, 
              controller: _githubController
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: "LinkedIn URL", 
              prefixIcon: Icons.business, 
              controller: _linkedinController
            ),

            const SizedBox(height: 50), // Bottom padding
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildEditableExperienceCard(ThemeData theme, Map<String, dynamic> item, int index) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerTheme.color!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (item['color'] as Color).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.business_center, size: 20, color: item['color'] as Color),
        ),
        title: Text(item['role'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${item['company']} • ${item['date']}"),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.grey),
          onPressed: () => _openExperienceSheet(context, index: index, data: item),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text, 
        style: TextStyle(
          color: theme.colorScheme.primary, 
          fontWeight: FontWeight.bold, 
          fontSize: 12, 
          letterSpacing: 1.2
        ),
      ),
    );
  }

  // --- LOGIC METHODS ---

  void _addSkill() {
    final text = _skillInputController.text.trim();
    if (text.isNotEmpty && !_skills.contains(text)) {
      setState(() {
        _skills.add(text);
        _skillInputController.clear();
      });
    }
  }

  Future<void> _openExperienceSheet(BuildContext context, {int? index, Map<String, dynamic>? data}) async {
    // Requires ExperienceFormSheet (provided in previous step)
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => ExperienceFormSheet(
        initialData: data?.map((k, v) => MapEntry(k, v.toString())),
      ),
    );

    if (result != null) {
      setState(() {
        if (result['delete'] == true && index != null) {
          _experience.removeAt(index);
        } else if (index != null) {
          // Edit existing item, preserve color
          _experience[index] = {
             ...result,
             'color': _experience[index]['color'], 
          };
        } else {
          // Add new item to top
          _experience.insert(0, {
            ...result,
            'color': Colors.blueAccent, // Default color for new entries
          });
        }
      });
    }
  }

  void _saveProfile() {
    // In a real app, send data to API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully!")),
    );
    Navigator.pop(context);
  }
}