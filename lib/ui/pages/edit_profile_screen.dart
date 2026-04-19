import 'dart:io';
import 'dart:typed_data';

import 'package:code_mate/data/models/user_model.dart';
import 'package:code_mate/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/custom_input_field.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController,
      _roleController,
      _bioController,
      _githubController,
      _linkedinController,
      _portfolioController;
  final _skillInputController = TextEditingController();

  late List<String> _skills;
  late List<Map<String, dynamic>> _experience;
  bool _isSaving = false;
  bool _isUploadingPicture = false;

  // Tracks the current profile picture state:
  //   • null          → use widget.user.profilePicture (original)
  //   • File          → local preview while upload is in progress
  //   • Uint8List     → server-confirmed bytes after a successful upload
  dynamic _resolvedPicture; // null | File | Uint8List | String (url)

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _roleController = TextEditingController(text: widget.user.headline);
    _bioController = TextEditingController(text: widget.user.bio);
    _githubController = TextEditingController(text: widget.user.githubURI);
    _linkedinController = TextEditingController(text: widget.user.linkedinURI);
    _portfolioController = TextEditingController(
      text: widget.user.portfolioURI,
    );
    _skills = List<String>.from(widget.user.skills);
    _experience = List<Map<String, dynamic>>.from(widget.user.experience);
  }

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _roleController,
      _bioController,
      _githubController,
      _linkedinController,
      _portfolioController,
      _skillInputController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ─── Avatar provider ───────────────────────────────────────────────────────
  // Priority:
  //   1. Server-confirmed Uint8List (returned after a successful upload)
  //   2. Local File (immediate preview while uploading)
  //   3. Original value from widget.user (String URL or Uint8List)
  //   4. Hard-coded fallback
  ImageProvider _getAvatarProvider() {
    // 1. Server-confirmed bytes
    if (_resolvedPicture is Uint8List) {
      return MemoryImage(_resolvedPicture as Uint8List);
    }

    // 2. Local file preview
    if (_resolvedPicture is File) {
      return FileImage(_resolvedPicture as File);
    }

    // 3. Original picture from server
    final pic = widget.user.profilePicture;
    if (pic is Uint8List && pic.isNotEmpty) return MemoryImage(pic);
    if (pic is String && pic.startsWith('http')) return NetworkImage(pic);

    // 4. Fallback
    return const NetworkImage('https://i.pravatar.cc/300?img=11');
  }

  // ─── Pick & upload ─────────────────────────────────────────────────────────
  Future<void> _pickAndUploadImage() async {
    final XFile? image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (image == null) return;

    // Show local preview immediately while the upload runs.
    setState(() {
      _resolvedPicture = File(image.path);
      _isUploadingPicture = true;
    });

    final (success, message, updatedUser) = await UserService()
        .uploadProfilePicture(File(image.path));

    if (!mounted) return;

    setState(() {
      _isUploadingPicture = false;
      if (success && updatedUser != null) {
        // Replace the local File with the server-confirmed picture so the
        // avatar stays in sync with what is actually stored in the database.
        final serverPic = updatedUser.profilePicture;
        if (serverPic is Uint8List && serverPic.isNotEmpty) {
          _resolvedPicture = serverPic;
        } else if (serverPic is String && serverPic.startsWith('http')) {
          _resolvedPicture = serverPic; // handled by _getAvatarProvider
        }
        // If the server returned nothing useful, keep the local File preview.
      }
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ─── Save profile ──────────────────────────────────────────────────────────
  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final (success, message) = await UserService().updateProfile(
      name: _nameController.text.trim(),
      headline: _roleController.text.trim(),
      bio: _bioController.text.trim(),
      githubURI: _githubController.text.trim(),
      linkedinURI: _linkedinController.text.trim(),
      portfolioURI: _portfolioController.text.trim(),
      skills: _skills,
    );
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    if (success) Navigator.pop(context, true);
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          _isSaving
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _saveProfile,
                  child: Text(
                    'Save',
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
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _getAvatarProvider(),
                    // Show spinner overlay while uploading.
                    child: _isUploadingPicture
                        ? const CircularProgressIndicator(color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _isUploadingPicture ? null : _pickAndUploadImage,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.colorScheme.primary,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildLabel(theme, 'BASIC INFO'),
            CustomInputField(
              label: 'Full Name',
              prefixIcon: Icons.person_outline,
              controller: _nameController,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Headline',
              prefixIcon: Icons.work_outline,
              controller: _roleController,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Bio',
              prefixIcon: Icons.info_outline,
              controller: _bioController,
            ),
            const SizedBox(height: 40),
            _buildLabel(theme, 'SKILLS'),
            Row(
              children: [
                Expanded(
                  child: CustomInputField(
                    label: 'Add Skill',
                    prefixIcon: Icons.bolt,
                    controller: _skillInputController,
                  ),
                ),
                IconButton.filled(
                  onPressed: () {
                    if (_skillInputController.text.isNotEmpty) {
                      setState(() {
                        _skills.add(_skillInputController.text.trim());
                        _skillInputController.clear();
                      });
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _skills
                  .map(
                    (s) => Chip(
                      label: Text(s),
                      onDeleted: () => setState(() => _skills.remove(s)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 40),
            _buildLabel(theme, 'SOCIALS'),
            CustomInputField(
              label: 'GitHub',
              prefixIcon: Icons.code,
              controller: _githubController,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'LinkedIn',
              prefixIcon: Icons.business,
              controller: _linkedinController,
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(ThemeData theme, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text,
      style: TextStyle(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
        fontSize: 12,
        letterSpacing: 1.2,
      ),
    ),
  );
}
