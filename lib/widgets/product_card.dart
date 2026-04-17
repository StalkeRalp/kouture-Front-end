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
        
        final Color buttonColor = id.hashCode % 2 == 0 ? _salmon : _darkNavy;

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
              // ─── Image container ───
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Image
                    Hero(
                      tag: '${heroPrefix}_product_$id',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          img,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () {
                          MockFirebase().toggleFavorite(id);
                          if (onFavoriteTap != null) onFavoriteTap!();
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            MockFirebase().isFavorite(id) ? Icons.favorite : Icons.favorite_border,
                            color: MockFirebase().isFavorite(id) ? _salmon : Colors.grey,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    // Bouton panier centré en bas (déborde légèrement)
                    Positioned(
                      bottom: -14,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            MockFirebase().addToCart(product);
                            if (onAddToCartTap != null) onAddToCartTap!();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(Translator.t('added_to_cart'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                backgroundColor: buttonColor,
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: buttonColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: buttonColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              // ─── Nom & prix ───
              Text(
                name,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                displayPrice,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

