import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'responsive_helper.dart';
class NavItem {
  final String label;
  final dynamic icon;
  final dynamic activeIcon;

  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

class CurvedNavBar extends StatefulWidget {
  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;
  final double height;

  const CurvedNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.activeColor = const Color(0xFFFF8C8C), // Signature Rose
    this.inactiveColor = const Color(0xFF9E9E9E), // Grey 400
    this.height = 75.0, // Default base height
  });

  @override
  State<CurvedNavBar> createState() => _CurvedNavBarState();
}

class _CurvedNavBarState extends State<CurvedNavBar> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  late double _startingLoc;
  int _oldIndex = 0;

  @override
  void initState() {
    super.initState();
    _oldIndex = widget.currentIndex;
    _startingLoc = _oldIndex.toDouble();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: _startingLoc, end: _startingLoc).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(CurvedNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _startingLoc = _animation.value;
      _animation = Tween<double>(
        begin: _startingLoc,
        end: widget.currentIndex.toDouble(),
      ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
      );
      _animController.forward(from: 0.0);
      _oldIndex = oldWidget.currentIndex;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.transparent,
      height: context.h(widget.height), // Exactly the responsive size of the bar
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final double sectionWidth = width / widget.items.length;
              final double locCenter = (_animation.value * sectionWidth) + (sectionWidth / 2);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // ─── Background Curved Bar ───
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: context.h(widget.height),
                    child: CustomPaint(
                      painter: _NavCustomPainter(
                        loc: locCenter,
                        color: widget.backgroundColor,
                      ),
                      child: Container(
                        height: context.h(widget.height),
                        // Padding to render standard tabs evenly
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),

                  // ─── Les Items Inactifs + Textes ───
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: context.h(widget.height),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(widget.items.length, (index) {
                        final item = widget.items[index];
                        final bool isSelected = index == widget.currentIndex;

                        // Animation locale pour la disparition (l'icône remonte et disparait ici)
                        final isAnimatingToThis = widget.currentIndex == index && _animController.isAnimating;
                        final isAnimatingFromThis = _oldIndex == index && _animController.isAnimating;
                        
                        double opacity = 1.0;
                        if (isSelected && !_animController.isAnimating) {
                          opacity = 0.0;
                        } else if (isAnimatingToThis) {
                          opacity = 1.0 - _animController.value;
                        } else if (isAnimatingFromThis) {
                          opacity = _animController.value;
                        }

                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (index != widget.currentIndex) {
                              widget.onTap(index);
                            }
                          },
                          child: Container(
                            width: sectionWidth,
                            alignment: Alignment.center,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 100),
                              opacity: opacity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  HugeIcon(icon: item.icon, color: widget.inactiveColor,
                                    size: context.w(26)),
                                  SizedBox(height: context.h(4)),
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      color: widget.inactiveColor,
                                      fontSize: context.sp(10),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // ─── L'Icône Active (La Boule Encastrée) ───
                  Positioned(
                    bottom: context.h(20), // Responsive bottom positioning
                    left: locCenter - context.w(25), // diameter responsive, radius responsive
                    child: Container(
                      width: context.w(50),
                      height: context.w(50),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.activeColor,
                        // AUCUNE OMBRE ICI : supprime l'effet de flottage et donne un effet de "pièce encastrée" (cut shape)
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeInBack,
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: FadeTransition(opacity: animation, child: child),
                            );
                          },
                          child: HugeIcon(icon: widget.items[_animation.value.round()].activeIcon, key: ValueKey<int>(_animation.value.round()),
                            color: Colors.white,
                            size: context.w(24),),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// ─── Custom Painter for the Bezier Cutout ───
class _NavCustomPainter extends CustomPainter {
  final double loc;
  final Color color;

  _NavCustomPainter({required this.loc, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Cutout parameters : un creux de la hauteur exacte de la boule
    final double curveWidth = Responsive.w(76.0);
    final double curveDepth = Responsive.h(55.0); // La boule va jusqu'à Y=55 responsive

    path.moveTo(0, 0);

    // Ligne droite de la gauche jusqu'au début du creux
    final double leftEdge = loc - (curveWidth / 2);
    if (leftEdge > 0) {
      path.lineTo(leftEdge, 0);
    }

    // Un creux franc et régulier qui épouse parfaitement la forme encastrée
    path.cubicTo(
      loc - 15, 0,
      loc - 25, curveDepth,
      loc, curveDepth,
    );

    path.cubicTo(
      loc + 25, curveDepth,
      loc + 15, 0,
      loc + (curveWidth / 2), 0,
    );

    // Fin de la ligne droite à droite
    path.lineTo(width, 0);
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    // Ombre douce, premium et diffuse (blur étendu)
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.2), 16.0, true);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NavCustomPainter oldDelegate) {
    return oldDelegate.loc != loc || oldDelegate.color != color;
  }
}
