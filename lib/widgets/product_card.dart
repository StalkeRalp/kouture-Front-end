import 'package:flutter/material.dart';
import '../backend/translator.dart';
import '../backend/mock_firebase.dart';
import '../screens/product_detail/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onAddToCartTap;
  final String heroPrefix;

  const ProductCard({
    super.key,
    required this.product,
    this.onFavoriteTap,
    this.onAddToCartTap,
    this.heroPrefix = '',
  });

  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _darkNavy = Color(0xFF0D0D26);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        final String id = product['id']?.toString() ?? '';
        final String name = product['name']?.toString() ?? 'Produit';
        final String? priceStr = product['price']?.toString();
        final String? currency = product['currency']?.toString();
        final String displayPrice = priceStr != null ? '$priceStr ${currency ?? "XAF"}' : '';
        
        String img = '';
        if (product['image'] != null) {
          img = product['image']!;
        } else if (product['images'] != null && (product['images'] as List).isNotEmpty) {
          img = product['images'][0];
        }

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context, 
              ProductDetailScreen.routeName, 
              arguments: {...product, 'heroPrefix': heroPrefix}
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ─── Image Container with Cutout ───
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // The Clipped Image
                    Positioned.fill(
                      child: Hero(
                        tag: '${heroPrefix}_product_$id',
                        child: ClipPath(
                          clipper: ProductCardClipper(),
                          child: Image.network(
                            img,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(32),
                              ),
                              child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Glassmorphism Favorite Button
                    Positioned(
                      top: 15,
                      right: 15,
                      child: GestureDetector(
                        onTap: () {
                          MockFirebase().toggleFavorite(id);
                          if (onFavoriteTap != null) onFavoriteTap!();
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            MockFirebase().isFavorite(id) ? Icons.favorite : Icons.favorite_border,
                            color: MockFirebase().isFavorite(id) ? _salmon : _darkNavy,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    
                    // The "Pop-out" Cart Button
                    Positioned(
                      bottom: -25,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            MockFirebase().addToCart(product);
                            if (onAddToCartTap != null) onAddToCartTap!();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  Translator.t('added_to_cart'), 
                                  style: const TextStyle(fontWeight: FontWeight.bold)
                                ),
                                backgroundColor: _salmon,
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _salmon,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _salmon.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 35),
              
              // ─── Product Details ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _darkNavy,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      displayPrice,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: _darkNavy,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A custom clipper to create the concave "vague" cutout at the bottom center.
class ProductCardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double radius = 32.0;
    const double cutoutRadius = 38.0; // Size of the concave cutout
    
    final Path path = Path()
      // Start at top-left
      ..moveTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      
      // Top line to top-right
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      
      // Right line to bottom-right
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(size.width, size.height, size.width - radius, size.height)
      
      // Bottom line with CUTOUT
      ..lineTo(size.width / 2 + cutoutRadius, size.height)
      // Concave arc
      ..arcToPoint(
        Offset(size.width / 2 - cutoutRadius, size.height),
        radius: const Radius.circular(cutoutRadius),
        clockwise: false, // Concave effect
      )
      
      // Bottom line to bottom-left
      ..lineTo(radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..close();
      
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}


