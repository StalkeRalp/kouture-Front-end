import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../backend/translator.dart';
import '../auth/login_screen.dart';
import '../../widgets/responsive_helper.dart';
import 'package:hugeicons/hugeicons.dart';

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

  List<OnboardingData> get _pages => [
    OnboardingData(
      title: Translator.t('onb_title_1'),
      description: Translator.t('onb_desc_1'),
      color: const Color(0xFFFF8C8C),
      icon: HugeIcons.strokeRoundedSparkles,
      assetPath: 'assets/onboarding/tailor_artisan.png',
      tag: Translator.t('onb_tag_1'),
    ),
    OnboardingData(
      title: Translator.t('onb_title_2'),
      description: Translator.t('onb_desc_2'),
      color: const Color(0xFF0D0D26),
      icon: HugeIcons.strokeRoundedHandPointingRight01,
      assetPath: 'assets/onboarding/stitch_detail.png',
      tag: Translator.t('onb_tag_2'),
    ),
    OnboardingData(
      title: Translator.t('onb_title_3'),
      description: Translator.t('onb_desc_3'),
      color: const Color(0xFFFF8C8C),
      icon: HugeIcons.strokeRoundedRuler,
      assetPath: 'assets/onboarding/perfect_fit_model.png',
      tag: Translator.t('onb_tag_3'),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _scrollOffset = _pageController.offset / (MediaQuery.of(context).size.width > 0 ? MediaQuery.of(context).size.width : 1.0);
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
            bottom: context.h(40),
            left: context.w(24),
            right: context.w(24),
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
          SizedBox(height: context.h(60)),
          // 📸 Image Container with Shadow and Parallax
          Container(
            height: context.w(327), // Defined width for image container
            margin: EdgeInsets.symmetric(horizontal: context.w(24)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: page.color.withValues(alpha: 0.15),
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
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: context.h(40)),

          // 📝 Text Content Step-in Animation
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(32)),
            child: Column(
              children: [
                // Tag / Badge (Surprise 2: Elegant Animated Badge)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(8)),
                  decoration: BoxDecoration(
                    color: page.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.w(30)),
                  ),
                  child: Text(
                    page.tag,
                    style: TextStyle(
                      fontSize: context.sp(12),
                      fontWeight: FontWeight.w900,
                      color: page.color,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                SizedBox(height: context.h(24)),
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.sp(32),
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -1,
                    color: Color(0xFF0D0D26),
                  ),
                ),
                SizedBox(height: context.h(16)),
                Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: context.sp(16),
                    color: Colors.grey[500],
                    height: 1.6,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(140)), // Space for bottom nav
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
        SizedBox(height: context.h(32)),
        if (_currentPage < _pages.length - 1)
          Center(
            child: TextButton(
              onPressed: () => _pageController.jumpToPage(_pages.length - 1),
              child: Text(
                Translator.t('skip'),
                style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ),
          )
        else
          Center(
            child: SizedBox(
              height: context.h(60),
              width: context.w(220),
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, LoginScreen.routeName),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D0D26),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.w(24))),
                  elevation: 10,
                  shadowColor: const Color(0xFF0D0D26).withValues(alpha: 0.3),
                ),
                child: Text(
                  Translator.t('start'),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(16), letterSpacing: 1.5),
                ),
              ),
            ),
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
      ..color = const Color(0xFF0D0D26).withValues(alpha: 0.03) // Very subtle
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
  final dynamic icon;
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