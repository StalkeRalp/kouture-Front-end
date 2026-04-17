import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../backend/mock_firebase.dart';
import '../main_navigation_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const String routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _dotsController;

  late Animation<double> _fadeAnim;
  late Animation<double> _slideAnim;
  late Animation<double> _scaleAnim;

  static const Color _coral = Color(0xFFFF8C8C);
  static const Color _navy = Color(0xFF0D0D26);

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController,
          curve: const Interval(0.0, 0.65, curve: Curves.easeOut)),
    );
    _slideAnim = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _mainController,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)),
    );
    _scaleAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _mainController,
          curve: const Interval(0.1, 0.7, curve: Curves.easeOutBack)),
    );

    _mainController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        if (MockFirebase().isAuthenticated) {
          Navigator.pushNamedAndRemoveUntil(context, MainNavigationScreen.routeName, (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, OnboardingScreen.routeName, (route) => false);
        }
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAF8),
      body: Stack(
        children: [
          // ── Filigrane de fond ──────────────────────────────────
          Positioned.fill(child: CustomPaint(painter: _FiligreePainter())),

          // ── Contenu principal ──────────────────────────────────
          Center(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (_, __) => Opacity(
                opacity: _fadeAnim.value,
                child: Transform.translate(
                  offset: Offset(0, _slideAnim.value),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo (Utilisation de LOGO3.png)
                      Transform.scale(
                        scale: _scaleAnim.value,
                        child: Image.asset(
                          'disign/LOGO3.png',
                          width: 250,
                          height: 250,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Nom (Agrandissement de l'écriture)
                      const Text(
                        'KOUTURE',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 10,
                          color: _navy,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Séparateur diamant
                      _buildDivider(),
                      const SizedBox(height: 16),

                      // Tagline (Agrandissement de l'écriture)
                      Text(
                        "L'art du sur-mesure",
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[400],
                          letterSpacing: 2,
                          fontFamily: 'CormorantGaramond',
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Loader dots
                      _AnimatedDots(controller: _dotsController),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 0.8,
          color: _coral.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 8),
        Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: 6,
            height: 6,
            color: _coral.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 48,
          height: 0.8,
          color: _coral.withValues(alpha: 0.4),
        ),
      ],
    );
  }
}

// ─── Dots animés ───────────────────────────────────────────────────────────────

class _AnimatedDots extends StatelessWidget {
  const _AnimatedDots({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final phase = ((controller.value - i * 0.22) % 1.0).clamp(0.0, 1.0);
          final opacity = 0.25 + 0.75 * math.sin(phase * math.pi);
          final scale = 0.7 + 0.3 * math.sin(phase * math.pi);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF8C8C).withValues(alpha: opacity),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Filigrane CustomPainter ───────────────────────────────────────────────────

class _FiligreePainter extends CustomPainter {
  static const Color coral = Color(0xFFFF8C8C);
  static const Color navy = Color(0xFF0D0D26);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Grille de points subtils
    final dotPaint = Paint()..color = navy.withValues(alpha: 0.06);
    for (double x = 10; x < w; x += 20) {
      for (double y = 10; y < h; y += 20) {
        canvas.drawCircle(Offset(x, y), 0.9, dotPaint);
      }
    }

    // 2. Grille de losanges corail très légers
    final diamondPaint = Paint()
      ..color = coral.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;
    for (double x = 0; x < w; x += 40) {
      for (double y = 0; y < h; y += 40) {
        final path = Path()
          ..moveTo(x + 20, y + 2)
          ..lineTo(x + 38, y + 20)
          ..lineTo(x + 20, y + 38)
          ..lineTo(x + 2, y + 20)
          ..close();
        canvas.drawPath(path, diamondPaint);
      }
    }

    // 3. Masque radial central (efface le milieu pour ne pas parasiter le logo)
    final mask = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.45,
        colors: [
          const Color(0xFFFAFAF8),
          const Color(0xFFFAFAF8).withValues(alpha: 0.0),
        ],
        stops: const [0.3, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), mask);

    // 4. Ornements de coins
    _drawCorner(canvas, Offset.zero, 1, 1, coral);
    _drawCorner(canvas, Offset(w, 0), -1, 1, coral);
    _drawCorner(canvas, Offset(0, h), 1, -1, coral);
    _drawCorner(canvas, Offset(w, h), -1, -1, coral);

    // 5. Lignes diagonales fines (style patron de couture)
    final linePaint = Paint()
      ..color = navy.withValues(alpha: 0.035)
      ..strokeWidth = 0.5;
    for (double offset = -h; offset < w + h; offset += 80) {
      canvas.drawLine(Offset(offset, 0), Offset(offset + h, h), linePaint);
    }

    // 6. Grande rosace centrale fantôme
    final rosacePaint = Paint()
      ..color = navy.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    final cx = w / 2;
    final cy = h / 2;
    for (final r in [100.0, 130.0, 160.0]) {
      canvas.drawCircle(Offset(cx, cy), r, rosacePaint);
    }
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + 160 * math.cos(angle), cy + 160 * math.sin(angle)),
        rosacePaint,
      );
    }

    // 7. Lignes horizontales haut/bas
    final borderLinePaint = Paint()
      ..color = coral.withValues(alpha: 0.18)
      ..strokeWidth = 0.5;
    canvas.drawLine(Offset(24, 52), Offset(w - 24, 52), borderLinePaint);
    canvas.drawLine(Offset(24, h - 52), Offset(w - 24, h - 52), borderLinePaint);

    // 8. Petits losanges latéraux
    final accentPaint = Paint()..color = coral.withValues(alpha: 0.18);
    for (final offset in [Offset(10, h / 2 - 20), Offset(10, h / 2 + 20),
                           Offset(w - 10, h / 2 - 20), Offset(w - 10, h / 2 + 20)]) {
      final p = Path()
        ..moveTo(offset.dx, offset.dy - 4)
        ..lineTo(offset.dx + 4, offset.dy)
        ..lineTo(offset.dx, offset.dy + 4)
        ..lineTo(offset.dx - 4, offset.dy)
        ..close();
      canvas.drawPath(p, accentPaint);
    }
  }

  void _drawCorner(Canvas canvas, Offset origin, double sx, double sy, Color color) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final p1 = Path()
      ..moveTo(origin.dx, origin.dy)
      ..quadraticBezierTo(
        origin.dx + sx * 50, origin.dy,
        origin.dx + sx * 50, origin.dy + sy * 50,
      );
    canvas.drawPath(p1, paint);

    final p2 = Path()
      ..moveTo(origin.dx, origin.dy)
      ..quadraticBezierTo(
        origin.dx, origin.dy + sy * 50,
        origin.dx + sx * 50, origin.dy + sy * 50,
      );
    canvas.drawPath(p2, paint);

    // Petit point décoratif
    final dotPaint = Paint()..color = color.withValues(alpha: 0.25);
    canvas.drawCircle(
      Offset(origin.dx + sx * 14, origin.dy + sy * 14),
      2.5, dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}