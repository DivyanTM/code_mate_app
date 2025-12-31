import 'package:flutter/material.dart';
import 'package:code_mate/ui/widgets/dev_match_card.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:code_mate/ui/pages/team_list_screen.dart';

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
              // TODO: Implement filter bottom sheet
            },
          ),
          IconButton(
            icon: Icon(
              Icons.message_outlined,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              // TODO: Implement filter bottom sheet
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
          if(index==1){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TeamsListScreen()),
            )
          }
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
