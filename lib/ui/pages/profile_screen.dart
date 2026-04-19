import 'package:code_mate/data/sources/global_state.dart';
import 'package:code_mate/ui/pages/edit_profile_screen.dart';
import 'package:code_mate/ui/pages/login_page.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // We use CustomScrollView for that "Social Media" collapsing header effect
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, theme),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16), // Space for overlapping avatar
                  _buildProfileHeader(theme),
                  const SizedBox(height: 24),
                  _buildStatsRow(theme),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),
                  _buildSocialLinks(context, theme),
                  const SizedBox(height: 32),
                  _buildSectionHeader(theme, "Tech Stack", Icons.layers),
                  const SizedBox(height: 16),
                  _buildSkillsWrap(theme),
                  const SizedBox(height: 32),
                  _buildSectionHeader(theme, "Experience", Icons.work_history),
                  const SizedBox(height: 16),
                  _buildExperienceTimeline(theme),
                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // WIRING: Navigate to Edit Screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
          );
        },
        icon: const Icon(Icons.edit_outlined),
        label: const Text("Edit Profile"),
      ),
    );
  }

  // 1. THE FANCY COLLAPSING HEADER
  Widget _buildSliverAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Cover Photo
            Positioned.fill(
              bottom: 40, // Leave room for the avatar half-out
              child: Image.network(
                "https://images.unsplash.com/photo-1550439062-609e1531270e?q=80&w=2070&auto=format&fit=crop",
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.2), // Slight dim for text
                colorBlendMode: BlendMode.darken,
              ),
            ),
            // The "Curved" cut at the bottom of the banner
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
            // The Avatar
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(4), // White border effect
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: const NetworkImage(
                    "https://i.pravatar.cc/300?img=11",
                  ),
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded, color: Colors.white),
          onPressed: () {
            GlobalState().clearPrefs();
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () {
            // Reuse the same navigation
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  // 2. NAME AND BIO
  Widget _buildProfileHeader(ThemeData theme) {
    return Column(
      children: [
        Text(
          "Alex Rivera",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Senior Backend Architect",
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Building scalable distributed systems. Open source enthusiast. Coffee addict ☕",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(width: 4),
            Text(
              "San Francisco, CA",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 3. STATS ROW (Social Proof)
  Widget _buildStatsRow(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(theme, "245", "Connections"),
          Container(width: 1, height: 40, color: theme.dividerTheme.color),
          _buildStatItem(theme, "12", "Projects"),
          Container(width: 1, height: 40, color: theme.dividerTheme.color),
          _buildStatItem(theme, "4.9", "Rating", isRating: true),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    String value,
    String label, {
    bool isRating = false,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (isRating) ...[
              const SizedBox(width: 2),
              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // 4. SOCIAL LINKS (Icon Row)
  // Update _buildSocialLinks inside ProfileScreen

  Widget _buildSocialLinks(BuildContext context, ThemeData theme) {
    // Map logic to specific URLs
    final socialItems = [
      {
        'icon': Icons.code,
        'color': Colors.black87,
        'url': 'https://github.com',
      },
      {
        'icon': Icons.business,
        'color': const Color(0xFF0077B5),
        'url': 'https://linkedin.com',
      },
      {
        'icon': Icons.language,
        'color': theme.colorScheme.primary,
        'url': 'https://alex.dev',
      },
      {
        'icon': Icons.alternate_email,
        'color': Colors.redAccent,
        'url': 'mailto:alex@email.com',
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: socialItems.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: InkWell(
            // WIRING: Open the specific URL
            onTap: () => _launchSocialUrl(context, item['url'] as String),
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (item['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item['icon'] as IconData,
                color: item['color'] as Color,
                size: 24,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Helper method to handle external links
  void _launchSocialUrl(BuildContext context, String url) {
    // In a real app, use: await launchUrl(Uri.parse(url));
    // For now, we show a confirmation snackbar to prove it works
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Opening $url...")));
  }

  // 5. SKILLS SECTION (Styled Chips)
  Widget _buildSkillsWrap(ThemeData theme) {
    final skills = [
      "Flutter",
      "Go",
      "AWS",
      "Kubernetes",
      "gRPC",
      "PostgreSQL",
      "Docker",
      "Redis",
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerTheme.color!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            skill,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 6. EXPERIENCE TIMELINE (Visual List)
  Widget _buildExperienceTimeline(ThemeData theme) {
    // Mock Data
    final experience = [
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: experience.length,
      itemBuilder: (context, index) {
        final item = experience[index];
        return IntrinsicHeight(
          child: Row(
            children: [
              // Timeline Line
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item['color'] as Color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: (item['color'] as Color).withOpacity(0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  if (index != experience.length - 1)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: theme.dividerTheme.color,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['role'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['company'] as String,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['date'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary.withOpacity(0.8),
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
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}
