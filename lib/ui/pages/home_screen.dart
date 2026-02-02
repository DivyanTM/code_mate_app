import 'package:code_mate/ui/pages/chat_list_screen.dart';
import 'package:code_mate/ui/pages/nearby_results_screen.dart';
import 'package:flutter/material.dart';
import 'package:code_mate/ui/widgets/dev_match_card.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:code_mate/ui/pages/team_list_screen.dart';
import 'package:code_mate/ui/pages/project_list_screen.dart';
import 'package:code_mate/ui/pages/profile_screen.dart';

class DiscoveryHomeScreen extends StatefulWidget {
  const DiscoveryHomeScreen({super.key});

  @override
  State<DiscoveryHomeScreen> createState() => _DiscoveryHomeScreenState();
}

class _DiscoveryHomeScreenState extends State<DiscoveryHomeScreen> {
  final CardSwiperController controller = CardSwiperController();
  int _currentIndex = 0; // For Bottom Navigation Tracking

  final List<Map<String, dynamic>> candidates = [
    {
      "name": "Alex Rivera",
      "role": "Backend Architect",
      "skills": ["Go", "Kubernetes", "gRPC"],
      "bio": "Building a distributed task scheduler. Need a Frontend lead.",
    },
    {
      "name": "Sarah Chen",
      "role": "UI/UX Designer",
      "skills": ["Figma", "Flutter", "Adobe XD"],
      "bio": "Specializing in clean, minimalist SaaS interfaces.",
    },
    {
      "name": "Marcus Bold",
      "role": "Fullstack Dev",
      "skills": ["Next.js", "Python", "AWS"],
      "bio": "Founder of 'DevLink'. Looking for contributors.",
    },
  ];

  String _activeFilter = "Teams";

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    List<Widget> cards = candidates.map((user) {
      return DevMatchCard(
        name: user['name'],
        role: user['role'],
        skills: List<String>.from(user['skills']),
        bio: user['bio'],
      );
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Discover Talent",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        // ADDED: Filter action from previous version
        actions: [
          IconButton(
            icon: Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
            onPressed: () {
              _showFilterSheet(context);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.message_outlined,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatListScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CardSwiper(
              controller: controller,
              cards: cards,
              onSwipe: (index, direction) {
                debugPrint('Swiped card $index to ${direction.name}');
              },
              numberOfCardsDisplayed: 2,
              padding: const EdgeInsets.all(24.0),
              threshold: 50,
            ),
          ),

          // Action Buttons (Swipe UI)
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _circularActionButton(
                  theme,
                  Icons.close,
                  Colors.redAccent,
                  () => controller.swipeLeft(),
                ),
                // ADDED: Middle button for quick chat
                _circularActionButton(
                  theme,
                  Icons.chat_bubble_outline_rounded,
                  theme.colorScheme.secondary,
                  () => print("Quick Chat Tapped"),
                ),
                _circularActionButton(
                  theme,
                  Icons.favorite,
                  Colors.greenAccent,
                  () => controller.swipeRight(),
                ),
              ],
            ),
          ),
        ],
      ),
      // ADDED: Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => {
          setState(() => _currentIndex = index),
          if (index == 1)
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TeamsListScreen()),
              ),
            }
          else if (index == 2)
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectsListScreen()),
              ),
            }
          else if (index == 3)
            {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              ),
            },
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.4),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            label: "Discover",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_work_rounded),
            label: "Teams",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline_rounded),
            label: "Projects",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        // StatefulBuilder allows us to update the checkmark inside the sheet
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 24.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Discovery Filter",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Apply the selected filter logic here
                          setState(() {}); // Update main screen if needed
                          Navigator.pop(context);
                        },
                        child: const Text("Done"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- 1. MUTUALLY EXCLUSIVE FILTERS ---
                  // Only ONE of these can be active at a time
                  _buildRadioFilterTile(
                    context,
                    label: "Teams",
                    icon: Icons.group_work_rounded,
                    color: Colors.blueAccent,
                    isSelected: _activeFilter == "Teams",
                    onTap: () => setSheetState(() => _activeFilter = "Teams"),
                  ),
                  const SizedBox(height: 12),

                  _buildRadioFilterTile(
                    context,
                    label: "Skills",
                    icon: Icons.bolt_rounded,
                    color: Colors.orangeAccent,
                    isSelected: _activeFilter == "Skills",
                    onTap: () => setSheetState(() => _activeFilter = "Skills"),
                  ),
                  const SizedBox(height: 12),

                  _buildRadioFilterTile(
                    context,
                    label: "Projects",
                    icon: Icons.rocket_launch_rounded,
                    color: Colors.purpleAccent,
                    isSelected: _activeFilter == "Projects",
                    onTap: () =>
                        setSheetState(() => _activeFilter = "Projects"),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),

                  // --- 2. SEPARATE MAP ROUTE ---
                  // This is NOT a filter, it's a navigation action
                  ListTile(
                    onTap: () {
                      Navigator.pop(context); // Close sheet
                      // Navigate to Map
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              NearbyMapScreen(filterType: _activeFilter),
                        ),
                      );
                    },
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.map_outlined,
                        color: Colors.green,
                      ),
                    ),
                    title: const Text(
                      "View on Map",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.green.withOpacity(0.5)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper for the Radio-style tiles
  Widget _buildRadioFilterTile(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isSelected ? color : Colors.grey),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? theme.colorScheme.onSurface : Colors.grey,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
          : const Icon(Icons.circle_outlined, color: Colors.grey),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.dividerTheme.color!,
          width: isSelected ? 2 : 1,
        ),
      ),
      tileColor: isSelected
          ? theme.colorScheme.primary.withOpacity(0.05)
          : null,
    );
  }

  Widget _circularActionButton(
    ThemeData theme,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}
