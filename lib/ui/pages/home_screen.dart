import 'package:code_mate/data/models/match_model.dart';
import 'package:code_mate/data/sources/global_state.dart';
import 'package:code_mate/service/match_service.dart';
import 'package:code_mate/ui/pages/chat_list_screen.dart';
import 'package:code_mate/ui/pages/login_page.dart';
import 'package:code_mate/ui/pages/nearby_results_screen.dart';
import 'package:code_mate/ui/pages/profile_screen.dart';
import 'package:code_mate/ui/pages/project_list_screen.dart';
import 'package:code_mate/ui/pages/team_list_screen.dart';
import 'package:code_mate/ui/widgets/dev_match_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class DiscoveryHomeScreen extends StatefulWidget {
  const DiscoveryHomeScreen({super.key});

  @override
  State<DiscoveryHomeScreen> createState() => _DiscoveryHomeScreenState();
}

class _DiscoveryHomeScreenState extends State<DiscoveryHomeScreen> {
  final CardSwiperController _swiperController = CardSwiperController();
  final MatchService _matchService = MatchService();

  int _currentIndex = 0;
  String _activeFilter = "Teams";

  List<MatchCandidate> _candidates = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _loadCandidates() async {
    debugPrint("🔄 _loadCandidates called");
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final candidates = await _matchService.getCandidates();
      setState(() => _candidates = candidates);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onSwipe(int index, CardSwiperDirection direction) async {
    if (index >= _candidates.length) return;
    final candidate = _candidates[index];

    if (direction == CardSwiperDirection.right) {
      final result = await _matchService.likeUser(candidate.id);
      if (!mounted) return;
      if (result.matched) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("🎉 It's a match with ${candidate.name}!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else if (direction == CardSwiperDirection.left) {
      await _matchService.rejectUser(candidate.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        actions: [
          IconButton(
            icon: Icon(Icons.tune_rounded, color: theme.colorScheme.primary),
            onPressed: () => _showFilterSheet(context),
          ),
          IconButton(
            icon: Icon(
              Icons.message_outlined,
              color: theme.colorScheme.primary,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatListScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildBody(theme)),
          Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _circularActionButton(
                  theme,
                  Icons.close,
                  Colors.redAccent,
                  () => _swiperController.swipeLeft(),
                ),
                _circularActionButton(
                  theme,
                  Icons.chat_bubble_outline_rounded,
                  theme.colorScheme.secondary,
                  () async {
                    await GlobalState().clearPrefs();
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                ),
                _circularActionButton(
                  theme,
                  Icons.favorite,
                  Colors.greenAccent,
                  () => _swiperController.swipeRight(),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TeamsListScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProjectsListScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => ProfileScreen()),
            );
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

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadCandidates,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_candidates.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            const Text("No more candidates nearby."),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadCandidates,
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
            ),
          ],
        ),
      );
    }

    final cards = _candidates.map((candidate) {
      return DevMatchCard(
        name: candidate.name,
        role: candidate.headline,
        skills: candidate.sharedSkills,
        bio: candidate.bio,
      );
    }).toList();

    return CardSwiper(
      controller: _swiperController,
      cards: cards,
      onSwipe: (index, direction) {
        _onSwipe(index, direction);
      },
      numberOfCardsDisplayed: 2,
      padding: const EdgeInsets.all(24.0),
      threshold: 50,
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
        return StatefulBuilder(
          builder: (context, setSheetState) {
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
                          setState(() {});
                          Navigator.pop(context);
                        },
                        child: const Text("Done"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                  ListTile(
                    onTap: () {
                      Navigator.pop(context);
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
              : (theme.dividerTheme.color ?? Colors.grey.shade300),
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
