import 'package:code_mate/data/models/match_model.dart';
import 'package:code_mate/data/sources/global_state.dart';
import 'package:code_mate/service/chat_api_service.dart';
import 'package:code_mate/service/match_service.dart';
import 'package:code_mate/service/socket_service.dart';
import 'package:code_mate/ui/pages/chat_detail_screen.dart';
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

  int _topIndex = 0;

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
    setState(() {
      _isLoading = true;
      _error = null;
      _topIndex = 0;
    });

    try {
      final candidates = await _matchService.getCandidates();

      // DEBUG — print every candidate in order
      for (int i = 0; i < candidates.length; i++) {
        debugPrint(
          'CANDIDATE[$i] id=${candidates[i].id} name=${candidates[i].name}',
        );
      }

      setState(() {
        _candidates = candidates;
        _topIndex = 0;
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startDM(String targetUserId, String userName) async {
    try {
      final room = await ChatApiService().openDM(targetUserId);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            roomId: room.id,
            title: userName,
            isChannel: false,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  Future<void> _onSwipe(int index, CardSwiperDirection direction) async {
    // DEBUG — what did the swiper report?
    debugPrint(
      'SWIPE: index=$index direction=$direction '
      'candidate=${index < _candidates.length ? _candidates[index].name : "OUT_OF_RANGE"}',
    );

    if (index >= _candidates.length) return;

    final swipedCandidate = _candidates[index];

    setState(() {
      _topIndex = index + 1;
    });

    debugPrint(
      'AFTER SWIPE: _topIndex=$_topIndex '
      'topCandidate=${_topCandidate?.name ?? "null"}',
    );

    if (direction == CardSwiperDirection.right) {
      final result = await _matchService.likeUser(swipedCandidate.id);
      if (!mounted) return;
      if (result.matched) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("🎉 It's a match with ${swipedCandidate.name}!"),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: "Message",
              textColor: Colors.white,
              onPressed: () =>
                  _startDM(swipedCandidate.id, swipedCandidate.name),
            ),
          ),
        );
      }
    } else if (direction == CardSwiperDirection.left) {
      await _matchService.rejectUser(swipedCandidate.id);
    }
  }

  MatchCandidate? get _topCandidate =>
      _topIndex < _candidates.length ? _candidates[_topIndex] : null;

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out of CodeMate?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await GlobalState().clearPrefs();
      SocketService().disconnect();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Discover Talent",
          style: TextStyle(fontWeight: FontWeight.w800),
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
              MaterialPageRoute(builder: (_) => const ChatListScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: _handleLogout,
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
                  () {
                    final candidate = _topCandidate;
                    // DEBUG — what does the message button think is on top?
                    debugPrint(
                      'MESSAGE BTN: _topIndex=$_topIndex '
                      'candidate=${candidate?.name ?? "null"} '
                      'id=${candidate?.id ?? "null"}',
                    );
                    if (candidate != null) {
                      _startDM(candidate.id, candidate.name);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No more candidates nearby.'),
                        ),
                      );
                    }
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
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TeamsListScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProjectsListScreen()),
            );
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
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
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadCandidates,
              child: const Text("Retry"),
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
            const Icon(Icons.people_outline_rounded, size: 48),
            const SizedBox(height: 12),
            const Text("No more candidates nearby."),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadCandidates,
              child: const Text("Refresh"),
            ),
          ],
        ),
      );
    }

    return CardSwiper(
      controller: _swiperController,
      cards: _candidates
          .map<Widget>(
            (candidate) => DevMatchCard(
              name: candidate.name,
              role: candidate.headline,
              skills: candidate.sharedSkills,
              bio: candidate.bio,
              profilePicture: candidate.profilePicture,
              distanceKm: candidate.distanceKm,
            ),
          )
          .toList(),
      onSwipe: _onSwipe,
      numberOfCardsDisplayed: 2,
      padding: const EdgeInsets.all(24.0),
      threshold: 50,
    );
  }

  void _showFilterSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Discovery Filter",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
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
                onTap: () => setSheetState(() => _activeFilter = "Projects"),
              ),
              const SizedBox(height: 24),
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
                leading: const Icon(Icons.map_outlined, color: Colors.green),
                title: const Text(
                  "View on Map",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              ),
            ],
          ),
        ),
      ),
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
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isSelected ? color : Colors.grey),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: Icon(
        isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
        color: isSelected ? color : Colors.grey,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
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
