import 'package:flutter/material.dart';

/// Un composant de fond premium pour les pages d'authentification.
/// Ajoute des bulles roses et des bandes légères comme demandé.
class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: [
        // ── Fond de base ─────────────────────────────────────
        Positioned.fill(
          child: Container(color: Colors.white),
        ),

        // ── Bandes Roses (Diagonal) ──────────────────────────
        Positioned.fill(
          child: CustomPaint(
            painter: _BandsPainter(),
          ),
        ),

        // ── Bulles Roses (Effet flou et doux) ────────────────
        _buildBubble(
          top: -100,
          right: -50,
          size: 300,
          opacity: 0.08,
        ),
        _buildBubble(
          bottom: size.height * 0.2,
          left: -150,
          size: 400,
          opacity: 0.1,
        ),
        _buildBubble(
          top: size.height * 0.15,
          left: size.width * 0.1,
          size: 150,
          opacity: 0.05,
        ),
        _buildBubble(
          bottom: -50,
          right: size.width * 0.2,
          size: 200,
          opacity: 0.07,
        ),

        // ── Contenu ──────────────────────────────────────────
        child,
      ],
    );
  }

  Widget _buildBubble({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFFFF8C8C).withValues(alpha: opacity),
              const Color(0xFFFF8C8C).withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _BandsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFDECEC).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Dessine quelques bandes diagonales larges et douces
    final path1 = Path()
      ..moveTo(0, h * 0.1)
      ..lineTo(w, h * 0.4)
      ..lineTo(w, h * 0.55)
      ..lineTo(0, h * 0.25)
      ..close();
    canvas.drawPath(path1, paint);

    final path2 = Path()
      ..moveTo(0, h * 0.6)
      ..lineTo(w, h * 0.85)
      ..lineTo(w, h * 1.0)
      ..lineTo(0, h * 0.75)
      ..close();
    canvas.drawPath(path2, paint);
    
    // Une bande inverse pour le style
    final paintLight = Paint()
      ..color = const Color(0xFFFFEFEF).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final path3 = Path()
      ..moveTo(w, h * 0.0)
      ..lineTo(0, h * 0.3)
      ..lineTo(0, h * 0.4)
      ..lineTo(w, h * 0.1)
      ..close();
    canvas.drawPath(path3, paintLight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
