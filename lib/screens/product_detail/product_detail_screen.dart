import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import '../../widgets/product_card.dart';
import './product_info_screen.dart';
import '../reviews/reviews_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  static const String routeName = '/product-detail';

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _darkNavy = Color(0xFF0D0D26);

  int _quantity = 1;
  late String _selectedSize;
  late String? _selectedColor;
  late Future<Map<String, dynamic>?> _productFuture;

  @override
  void initState() {
    super.initState();
    final productId = widget.product['id'].toString();
    _productFuture = MockFirebase().getProductById(productId);

    // Initial default values from passed simple product
    final sizes = widget.product['sizes'] as List? ?? [];
    _selectedSize = sizes.isNotEmpty ? sizes[0].toString() : 'unique';
    
    final colors = widget.product['colors'] as List? ?? [];
    _selectedColor = colors.isNotEmpty ? colors[0].toString() : null;
  }

  void _increment() => setState(() => _quantity++);
  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: _salmon)));
        }
        
        final p = snapshot.data ?? widget.product;
        
        final images = p['images'] as List? ?? [];
        final mainImage = images.isNotEmpty ? images[0] : '';
        final price = p['price'] ?? 0;
        final oldPrice = p['oldPrice'];
        final currency = p['currency'] ?? 'XAF';

        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header Image ───
                Stack(
                  children: [
                    Hero(
                      tag: '${widget.product['heroPrefix'] ?? ''}_product_${p['id']}',
                      child: Image.network(
                        mainImage,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.55,
                        fit: BoxFit.cover,
                      ),
                    ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCircleButton(
                          icon: Icons.chevron_left,
                          onTap: () => Navigator.pop(context),
                        ),
                        _buildCircleButton(
                          icon: Icons.share_outlined,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: AnimatedBuilder(
                    animation: MockFirebase(),
                    builder: (context, _) {
                      final isFav = MockFirebase().isFavorite(p['id'].toString());
                      return _buildCircleButton(
                        icon: isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? _salmon : Colors.grey,
                        onTap: () => MockFirebase().toggleFavorite(p['id'].toString()),
                      );
                    },
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Category
                  Text(
                    p['name'] ?? '',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${p['category'] ?? ''} Shirt',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Price & Rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              children: [
                                Text(
                                  '$price $currency',
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _salmon),
                                ),
                                if (oldPrice != null)
                                  Text(
                                    '$oldPrice $currency',
                                    style: TextStyle(
                                      fontSize: 16, 
                                      color: Colors.grey, 
                                      decoration: TextDecoration.lineThrough
                                    ),
                                  ),
                                if (p['discount'] != null && p['discount'] > 0)
                                  Text(
                                    '${p['discount']}% OFF',
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              children: [
                                ...List.generate(5, (i) => Icon(
                                  i < (p['rating']?.floor() ?? 0) ? Icons.star : Icons.star_border,
                                  color: Colors.amber, size: 18,
                                )),
                                Text('(${p['totalReviews'] ?? 0})', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, ReviewsScreen.routeName, arguments: p),
                                  child: const Text('See Reviews', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.underline))
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Time indicator (Mock)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                           Text('16hrs : 32mins', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[800])),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Vendor Section
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/vendor-profile', arguments: p['vendorId']),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${p['vendorId']}'), 
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p['vendorName'] ?? 'Vendeur', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('Boutique Officielle', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _salmon.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Visiter', style: TextStyle(color: _salmon, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Select Quantity
                  const Text('Select Quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  _buildQuantitySelector(),

                  const SizedBox(height: 25),

                  // Select Size
                  if ((p['sizes'] as List?)?.isNotEmpty ?? false) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Select Size: $_selectedSize', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSizeSelector(p['sizes'] as List),
                  ],

                  const SizedBox(height: 25),

                  // Select Color
                  if ((p['colors'] as List?)?.isNotEmpty ?? false) ...[
                    Text('Select Color: ${_selectedColor != null ? "Selected" : "None"}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    _buildColorSelector(p['colors'] as List),
                  ],

                  const SizedBox(height: 30),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            MockFirebase().addToCart(p, size: _selectedSize, color: _selectedColor, quantity: _quantity);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to cart!'), duration: Duration(seconds: 1)),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart_outlined),
                          label: const Text('Add to cart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _darkNavy,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Add to cart with selected options
                            MockFirebase().addToCart(
                              p,
                              quantity: _quantity,
                              size: _selectedSize,
                              color: _selectedColor,
                            );
                            // Go directly to checkout
                            Navigator.pushNamed(context, '/checkout');
                          },
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: const Text('Buy now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _salmon,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 55),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Expandables
                  _buildExpandableTile(
                    'Product Details', 
                    onTap: () => Navigator.pushNamed(
                      context, 
                      ProductInfoScreen.routeName, 
                      arguments: p
                    )
                  ),
                  const Divider(),
                  _buildExpandableTile(
                    'Specifications', 
                    subtitle: p['description'],
                    onTap: () => Navigator.pushNamed(
                      context, 
                      ProductInfoScreen.routeName, 
                      arguments: p
                    )
                  ),
                  
                  const SizedBox(height: 40),

                  // Reviews Selection
                  _buildReviewsSection(p['id'].toString()),

                  const SizedBox(height: 40),

                  // Similar Products
                  const Text('Similar Products', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 15),
                  _buildSimilarProducts(p['id'].toString()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
        },
    );
  }

  Widget _buildCircleButton({required IconData icon, Color? color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(icon, color: color ?? Colors.black, size: 24),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: _decrement, icon: const Icon(Icons.remove, size: 18)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          IconButton(onPressed: _increment, icon: const Icon(Icons.add, size: 18)),
        ],
      ),
    );
  }

  Widget _buildSizeSelector(List sizes) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sizes.length,
        itemBuilder: (context, index) {
          final size = sizes[index].toString();
          final isSelected = _selectedSize == size;
          return GestureDetector(
            onTap: () => setState(() => _selectedSize = size),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: isSelected ? _salmon : Colors.transparent, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 50,
                  height: 50,
                  color: isSelected ? _salmon.withValues(alpha: 0.1) : Colors.grey[100],
                  child: Center(
                    child: Text(size, style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? _salmon : Colors.black87
                    )),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorSelector(List colors) {
    return Row(
      children: colors.map((col) {
        final hex = col.toString();
        final color = _hexToColor(hex);
        final isSelected = _selectedColor == hex;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = hex),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? _salmon : Colors.transparent, width: 2),
              boxShadow: [
                if (isSelected) 
                  BoxShadow(color: _salmon.withValues(alpha: 0.3), blurRadius: 4, spreadRadius: 1)
              ]
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpandableTile(String title, {String? subtitle, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle, 
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection(String productId) {
    return FutureBuilder<List<dynamic>>(
      future: MockFirebase().getReviewsByProductId(productId),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();
        final reviews = snapshot.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, ReviewsScreen.routeName, arguments: widget.product),
                  child: const Text('View All', style: TextStyle(color: _salmon, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...reviews.take(2).map((r) => _buildReviewItem(r)),
          ],
        );
      },
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(r['userAvatar'] ?? ''),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r['userName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        Icons.star, 
                        color: i < (r['rating'] ?? 0) ? Colors.amber : Colors.grey[300], 
                        size: 12,
                      )),
                    ),
                  ],
                ),
              ),
              Text(r['date'] ?? '', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            r['comment'] ?? '',
            style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarProducts(String currentId) {
    if (currentId.isEmpty) return const SizedBox();
    
    return FutureBuilder<List<dynamic>>(
      future: MockFirebase().getProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) return const SizedBox();
        
        // Robust filtering and uniqueness
        final allProducts = snapshot.data as List<dynamic>;
        final seenIds = <String>{};
        final products = <dynamic>[];
        
        for (final item in allProducts) {
          final id = item['id']?.toString() ?? '';
          if (id.isEmpty || id == currentId || seenIds.contains(id)) continue;
          
          seenIds.add(id);
          products.add(item);
          if (products.length >= 4) break;
        }

        return GridView.builder(
          key: ValueKey('similar_grid_$currentId'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 18,
            crossAxisSpacing: 14,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, index) {
            final p = products[index];
            final mapped = {
              'id': p['id'].toString(),
              'name': p['name'].toString(),
              'price': p['price'], 
              'currency': p['currency'],
              'image': (p['images'] as List)[0].toString(),
            };
            return ProductCard(
              key: ValueKey('sim_card_${mapped['id']}'),
              product: mapped,
              onFavoriteTap: () {},
              onAddToCartTap: () {
                MockFirebase().addToCart(p);
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to cart!'), duration: Duration(seconds: 1)),
                );
              },
            );
          },
        );
      },
    );
  }
}
