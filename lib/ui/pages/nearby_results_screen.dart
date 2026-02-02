import 'package:flutter/material.dart';

class NearbyMapScreen extends StatelessWidget {
  final String filterType;

  const NearbyMapScreen({super.key, required this.filterType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true, // Allows map to go under the app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                "Searching: $filterType",
                style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Fake Map Background
          Container(
            color: const Color(0xFFE5E5E5), // Standard Map Gray
            child: Stack(
              children: [
                // Grid lines to simulate map blocks
                _buildGridLines(),
                // Dummy "Pins" scattered around
                _buildMapPin(context, 100, 150, Colors.blue),
                _buildMapPin(context, 250, 300, Colors.red),
                _buildMapPin(context, 80, 400, Colors.green),
                _buildMapPin(context, 300, 150, Colors.orange),
              ],
            ),
          ),

          // 2. Bottom "Near You" Card
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.radar_rounded, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("4 $filterType Found", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Text("Within 5km radius", style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {}, 
                    icon: const Icon(Icons.list_rounded),
                    style: IconButton.styleFrom(backgroundColor: Colors.grey[100]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.white,
        child: const Icon(Icons.my_location, color: Colors.black),
      ),
    );
  }

  // Helper to make it look like a map
  Widget _buildMapPin(BuildContext context, double top, double left, Color color) {
    return Positioned(
      top: top,
      left: left,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 16),
          ),
          // Triangle pointer
          ClipPath(
            clipper: _TriangleClipper(),
            child: Container(color: color, width: 10, height: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildGridLines() {
    return CustomPaint(
      size: Size.infinite,
      painter: _GridPainter(),
    );
  }
}

// Simple Painters to fake the map grid visual
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.withOpacity(0.2)..strokeWidth = 2;
    // Draw vertical lines
    for (double i = 0; i < size.width; i += 60) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    // Draw horizontal lines
    for (double i = 0; i < size.height; i += 60) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}