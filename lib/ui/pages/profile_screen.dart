import 'dart:typed_data';

import 'package:code_mate/data/models/user_model.dart';
import 'package:code_mate/data/sources/global_state.dart';
import 'package:code_mate/service/user_service.dart';
import 'package:code_mate/ui/pages/edit_profile_screen.dart';
import 'package:code_mate/ui/pages/login_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<UserModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    setState(() {
      _profileFuture = UserService().getMyProfile();
    });
  }

  // ─── Image provider ────────────────────────────────────────────────────────
  // Handles every shape the server can return:
  //   • Uint8List  → binary stored in MongoDB, converted by UserModel.fromJson
  //   • String URL → if the picture is stored as a URL
  //   • null       → no picture set yet
  ImageProvider _getProfileImage(dynamic profilePicture) {
    if (profilePicture == null) {
      debugPrint('[ProfileScreen] profilePicture is null → fallback');
      return const NetworkImage('https://i.pravatar.cc/300?img=11');
    }

    if (profilePicture is Uint8List) {
      if (profilePicture.isNotEmpty) {
        debugPrint(
          '[ProfileScreen] profilePicture is Uint8List (${profilePicture.length} bytes) → MemoryImage',
        );
        return MemoryImage(profilePicture);
      }
      debugPrint(
        '[ProfileScreen] profilePicture is empty Uint8List → fallback',
      );
      return const NetworkImage('https://i.pravatar.cc/300?img=11');
    }

    if (profilePicture is String) {
      if (profilePicture.startsWith('http')) {
        debugPrint('[ProfileScreen] profilePicture is URL → NetworkImage');
        return NetworkImage(profilePicture);
      }
      debugPrint(
        '[ProfileScreen] profilePicture is non-URL String ("$profilePicture") → fallback',
      );
      return const NetworkImage('https://i.pravatar.cc/300?img=11');
    }

    debugPrint(
      '[ProfileScreen] profilePicture unhandled type ${profilePicture.runtimeType} → fallback',
    );
    return const NetworkImage('https://i.pravatar.cc/300?img=11');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: FutureBuilder<UserModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load profile',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _loadProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _loadProfile(),
            child: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, theme, user),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        _buildProfileHeader(theme, user),
                        const SizedBox(height: 24),
                        _buildStatsRow(theme),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        _buildSocialLinks(context, theme, user),
                        const SizedBox(height: 32),
                        _buildSectionHeader(theme, 'Tech Stack', Icons.layers),
                        const SizedBox(height: 16),
                        _buildSkillsWrap(theme, user),
                        const SizedBox(height: 32),
                        _buildSectionHeader(
                          theme,
                          'Experience',
                          Icons.work_history,
                        ),
                        const SizedBox(height: 16),
                        _buildExperienceTimeline(theme, user),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FutureBuilder<UserModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(user: snapshot.data!),
                ),
              ).then((_) => _loadProfile()); // always reload after editing
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Profile'),
          );
        },
      ),
    );
  }

  // ─── Sliver app bar ────────────────────────────────────────────────────────
  Widget _buildSliverAppBar(
    BuildContext context,
    ThemeData theme,
    UserModel user,
  ) {
    return SliverAppBar(
      expandedHeight: 220.0,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned.fill(
              bottom: 40,
              child: Image.network(
                'https://images.unsplash.com/photo-1550439062-609e1531270e?q=80&w=2070&auto=format&fit=crop',
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: 0.2),
                colorBlendMode: BlendMode.darken,
              ),
            ),
            Positioned(
              bottom: 39,
              left: 0,
              right: 0,
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 50,
                  // Key forces Flutter to rebuild the CircleAvatar when the
                  // picture data changes, avoiding stale image cache.
                  key: ValueKey(
                    user.profilePicture is Uint8List
                        ? (user.profilePicture as Uint8List).length
                        : user.profilePicture.toString(),
                  ),
                  backgroundImage: _getProfileImage(user.profilePicture),
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white),
          onPressed: () {
            GlobalState().clearPrefs();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
        ),
      ],
    );
  }

  // ─── Profile header ────────────────────────────────────────────────────────
  Widget _buildProfileHeader(ThemeData theme, UserModel user) {
    return Column(
      children: [
        Text(
          user.name,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        if (user.headline.isNotEmpty)
          Text(
            user.headline,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        const SizedBox(height: 8),
        if (user.bio.isNotEmpty)
          Text(
            user.bio,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
      ],
    );
  }

  // ─── Stats row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerTheme.color ?? Colors.grey.shade300,
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatItem(value: '245', label: 'Connections'),
          _StatItem(value: '12', label: 'Projects'),
          _StatItem(value: '4.9', label: 'Rating', isRating: true),
        ],
      ),
    );
  }

  // ─── Social links ──────────────────────────────────────────────────────────
  Widget _buildSocialLinks(
    BuildContext context,
    ThemeData theme,
    UserModel user,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (user.githubURI.isNotEmpty)
          _buildSocialIcon(
            context,
            theme,
            Icons.code,
            Colors.black87,
            user.githubURI,
          ),
        if (user.linkedinURI.isNotEmpty)
          _buildSocialIcon(
            context,
            theme,
            Icons.business,
            const Color(0xFF0077B5),
            user.linkedinURI,
          ),
        if (user.portfolioURI.isNotEmpty)
          _buildSocialIcon(
            context,
            theme,
            Icons.language,
            theme.colorScheme.primary,
            user.portfolioURI,
          ),
        _buildSocialIcon(
          context,
          theme,
          Icons.alternate_email,
          Colors.redAccent,
          'mailto:${user.email}',
        ),
      ],
    );
  }

  Widget _buildSocialIcon(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    Color color,
    String url,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Opening $url...'))),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }

  // ─── Section header ────────────────────────────────────────────────────────
  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  // ─── Skills wrap ───────────────────────────────────────────────────────────
  Widget _buildSkillsWrap(ThemeData theme, UserModel user) {
    if (user.skills.isEmpty) {
      return const Text(
        'No skills added yet.',
        style: TextStyle(color: Colors.grey),
      );
    }
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: user.skills
          .map(
            (skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.dividerTheme.color ?? Colors.grey.shade300,
                ),
              ),
              child: Text(
                skill,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          )
          .toList(),
    );
  }

  // ─── Experience timeline ───────────────────────────────────────────────────
  Widget _buildExperienceTimeline(ThemeData theme, UserModel user) {
    if (user.experience.isEmpty) {
      return const Text(
        'No experience added.',
        style: TextStyle(color: Colors.grey),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: user.experience.length,
      itemBuilder: (context, index) {
        final item = user.experience[index];
        final dotColor = item['color'] != null
            ? Color(int.parse(item['color']))
            : theme.colorScheme.primary;
        return IntrinsicHeight(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (index != user.experience.length - 1)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: theme.dividerTheme.color,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['role'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        item['company'] ?? '',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      Text(
                        item['date'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Stat item ─────────────────────────────────────────────────────────────
class _StatItem extends StatelessWidget {
  final String value, label;
  final bool isRating;
  const _StatItem({
    required this.value,
    required this.label,
    this.isRating = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            if (isRating)
              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
          ],
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
