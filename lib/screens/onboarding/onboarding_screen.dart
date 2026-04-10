import 'package:flutter/material.dart';
import 'dart:math' as math;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  double _scrollOffset = 0.0;
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Héritage Artisanal',
      description: 'Découvrez l\'excellence du travail local. Nos artisans transforment les étoffes les plus nobles en chefs-d\'œuvre uniques.',
      color: const Color(0xFFFF8C8C),
      icon: Icons.auto_awesome,
      assetPath: 'assets/onboarding/tailor_artisan.png',
      tag: 'SAVOIR FAIRE',
    ),
    OnboardingData(
      title: 'Précision & Passion',
      description: 'Chaque point raconte une histoire. Accédez à la qualité supérieure du sur-mesure authentiquement africain.',
      color: const Color(0xFF0D0D26),
      icon: Icons.gesture_rounded,
      assetPath: 'assets/onboarding/stitch_detail.png',
      tag: 'ART ET PASSION',
    ),
    OnboardingData(
      title: 'Afrique Élégante',
      description: 'Portez votre culture avec fierté. Une coupe moderne et parfaite, conçue pour valoriser votre silhouette et votre héritage.',
      color: const Color(0xFFFF8C8C),
      icon: Icons.straighten_rounded,
      assetPath: 'assets/onboarding/perfect_fit_model.png',
      tag: 'COUPES PARFAITES',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _scrollOffset = _pageController.offset / MediaQuery.of(context).size.width;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 🎭 Parallax Background Pattern (Surprise 1: Bogolan Pattern)
          Positioned.fill(
            child: CustomPaint(
              painter: _BogolanBackgroundPainter(scrollOffset: _scrollOffset),
            ),
          ),

          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return _buildPage(page, index);
            },
          ),
          
          // Navigation & Indicators
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: _buildBottomNavigation(),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData page, int index) {
    // Parallax logic for image
    final double parallaxOffset = (_scrollOffset - index) * 50;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 60),
          // 📸 Image Container with Shadow and Parallax
          Container(
            height: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: page.color.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Stack(
                children: [
                  Transform.translate(
                    offset: Offset(parallaxOffset, 0),
                    child: Transform.scale(
                      scale: 1.1, // Slightly larger for parallax breathing room
                      child: Image.asset(
                        page.assetPath,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  // Subtle Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 48),

          // 📝 Text Content Step-in Animation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                // Tag / Badge (Surprise 2: Elegant Animated Badge)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: page.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    page.tag,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: page.color,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -1,
                    color: Color(0xFF0D0D26),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                    height: 1.6,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 140), // Space for bottom nav
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Column(
      children: [
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _pages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 8),
              height: 4,
              width: _currentPage == index ? 24 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? const Color(0xFFFF8C8C) : Colors.grey[200],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => _pageController.jumpToPage(_pages.length - 1),
                child: Text(
                  'PASSER',
                  style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 64,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutQuart,
                      );
                    } else {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D0D26),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 10,
                    shadowColor: const Color(0xFF0D0D26).withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == _pages.length - 1 ? 'COMMENCER' : 'SUIVANT',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Surprise: Bogolan Pattern Painter ──────────────────────────────────────────

class _BogolanBackgroundPainter extends CustomPainter {
  final double scrollOffset;
  _BogolanBackgroundPainter({required this.scrollOffset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0D0D26).withOpacity(0.03) // Very subtle
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final double patternSize = 100.0;
    final double parallaxIntensity = scrollOffset * 20.0;

    for (double x = -patternSize; x < size.width + patternSize; x += patternSize) {
      for (double y = 0; y < size.height; y += patternSize) {
        final double posX = x - parallaxIntensity;
        
        // Draw geometric Bogolan-style triangles & lines
        final path = Path()
          ..moveTo(posX, y)
          ..lineTo(posX + 20, y + 20)
          ..moveTo(posX + patternSize, y)
          ..lineTo(posX + patternSize - 20, y + 20)
          ..moveTo(posX + 10, y + 40)
          ..lineTo(posX + 30, y + 40);
        
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BogolanBackgroundPainter oldDelegate) =>
      oldDelegate.scrollOffset != scrollOffset;
}

class OnboardingData {
  final String title;
  final String description;
  final Color color;
  final IconData icon;
  final String assetPath;
  final String tag;

  OnboardingData({
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
    required this.assetPath,
    required this.tag,
  });
}