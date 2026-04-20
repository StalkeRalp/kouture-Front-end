import 'package:flutter/material.dart';
import '../../backend/translator.dart';
import '../../backend/mock_firebase.dart';
import '../reviews/reviews_screen.dart';
import 'product_info_screen.dart';
import 'product_images_screen.dart';
import '../vendor/vendor_profile_screen.dart';
import '../order/checkout_screen.dart';
import '../../widgets/product_card.dart';
import '../../widgets/responsive_helper.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart' as path;

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

  Future<void> _shareProduct(Map<String, dynamic> p) async {
    try {
      debugPrint('SHARE: Starting share for product ${p['id']}');
      
      // Show loading snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const ValueKey('share_snackbar'),
          content: Text(Translator.t('preparing_share')),
          duration: const Duration(seconds: 4),
          backgroundColor: _darkNavy,
        ),
      );

      final images = p['images'] as List? ?? [];
      final imageUrl = images.isNotEmpty ? images[0].toString() : '';
      
      final String shareText = "${p['name']}\n${p['price']} ${p['currency']}\n\n${Translator.t('check_this_out_on_kouture')}";

      if (imageUrl.isEmpty) {
        debugPrint('SHARE: No image found, sharing text only');
        await Share.share(shareText, subject: p['name']);
        return;
      }

      debugPrint('SHARE: Downloading image from $imageUrl');
      
      try {
        final response = await http.get(Uri.parse(imageUrl)).timeout(const Duration(seconds: 10));
        if (response.statusCode != 200) throw Exception('Download failed: ${response.statusCode}');

        final tempDir = await getTemporaryDirectory();
        final ext = path.extension(imageUrl).split('?')[0];
        final fileName = 'product_${p['id']}${ext.isEmpty ? '.jpg' : ext}';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);

        debugPrint('SHARE: Image saved at ${file.path}, launching share sheet');
        
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'image/jpeg')],
          text: shareText,
          subject: p['name'],
        );
      } catch (imageError) {
        debugPrint('SHARE: Image sharing failed ($imageError), falling back to text only');
        await Share.share(shareText, subject: p['name']);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } catch (e) {
      debugPrint('SHARE: Global error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
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
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context, 
                              ProductImagesScreen.routeName, 
                              arguments: {
                                'images': p['images'] ?? [mainImage],
                                'initialIndex': 0,
                              }
                            );
                          },
                          child: Hero(
                            tag: '${widget.product['heroPrefix'] ?? ''}_product_${p['id']}',
                            child: Image.network(
                              mainImage,
                              width: double.infinity,
                              height: context.h(450),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: EdgeInsets.all(context.w(16)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildCircleButton(
                                  icon: HugeIcons.strokeRoundedArrowLeft01,
                                  onTap: () => Navigator.pop(context),
                                ),
                                _buildCircleButton(
                                  icon: HugeIcons.strokeRoundedShare01,
                                  onTap: () => _shareProduct(p),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: context.h(20),
                          right: context.w(20),
                          child: _buildCircleButton(
                            icon: MockFirebase().isFavorite(p['id'].toString()) ? HugeIcons.strokeRoundedFavourite : HugeIcons.strokeRoundedFavourite,
                            color: MockFirebase().isFavorite(p['id'].toString()) ? _salmon : Colors.grey,
                            onTap: () => MockFirebase().toggleFavorite(p['id'].toString()),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: EdgeInsets.all(context.w(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  p['name'] ?? '',
                                  style: TextStyle(fontSize: context.sp(22), fontWeight: FontWeight.bold),
                                ),
                              ),
                              _buildCartShortcut(context, p),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${p['category'] ?? ''} Shirt',
                            style: TextStyle(color: Colors.grey[600], fontSize: context.sp(14)),
                          ),
                          
                          SizedBox(height: context.h(16)),
                          
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
                                          style: TextStyle(fontSize: context.sp(20), fontWeight: FontWeight.bold, color: _salmon),
                                        ),
                                        if (oldPrice != null)
                                          Text(
                                            '$oldPrice $currency',
                                            style: TextStyle(
                                              fontSize: context.sp(16), 
                                              color: Colors.grey, 
                                              decoration: TextDecoration.lineThrough
                                            ),
                                          ),
                                        if (p['discount'] != null && p['discount'] > 0)
                                          Text(
                                            '${p['discount']}% OFF',
                                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: context.sp(14)),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 4,
                                      children: [
                                        ...List.generate(5, (i) => HugeIcon(icon: i < (p['rating']?.floor() ?? 0) ? HugeIcons.strokeRoundedStars : HugeIcons.strokeRoundedStars, color: Colors.amber, size: context.w(18),)),
                                        Text('(${p['totalReviews'] ?? 0})', style: TextStyle(color: Colors.grey[600], fontSize: context.sp(12))),
                                        GestureDetector(
                                          onTap: () => Navigator.pushNamed(context, ReviewsScreen.routeName, arguments: p),
                                          child: Text(Translator.t('see_reviews'), style: TextStyle(fontSize: context.sp(12), fontWeight: FontWeight.bold, decoration: TextDecoration.underline))
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                   Text('16hrs : 32mins', style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(13), color: Colors.grey[800])),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, VendorProfileScreen.routeName, arguments: p['vendorId']),
                            child: Container(
                              padding: EdgeInsets.all(context.w(15)),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(context.w(15)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: context.w(20),
                                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${p['vendorId']}'), 
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p['vendorName'] ?? Translator.t('vendor'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(Translator.t('official_shop'), style: TextStyle(color: Colors.grey[600], fontSize: context.sp(12))),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _salmon.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(Translator.t('visit'), style: TextStyle(color: _salmon, fontWeight: FontWeight.bold, fontSize: context.sp(12))),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: context.h(25)),

                          Text(Translator.t('select_quantity'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(16))),
                          const SizedBox(height: 12),
                          _buildQuantitySelector(),

                          const SizedBox(height: 25),

                          if ((p['sizes'] as List?)?.isNotEmpty ?? false) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${Translator.t('select_size')}: $_selectedSize', style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(16))),
                              ],
                            ),
                            SizedBox(height: context.h(12)),
                            _buildSizeSelector(p['sizes'] as List),
                          ],

                          const SizedBox(height: 25),

                          if ((p['colors'] as List?)?.isNotEmpty ?? false) ...[
                            Text('${Translator.t('select_color')}: ${_selectedColor != null ? "Selected" : "None"}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(16))),
                            SizedBox(height: context.h(12)),
                            _buildColorSelector(p['colors'] as List),
                          ],

                          const SizedBox(height: 30),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    MockFirebase().addToCart(p, size: _selectedSize, color: _selectedColor, quantity: _quantity);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(Translator.t('added_to_cart')), duration: const Duration(seconds: 1)),
                                    );
                                  },
                                  icon: HugeIcon(icon: HugeIcons.strokeRoundedShoppingCart01, color: Colors.black, size: 24.0),
                                  label: Text(Translator.t('add_to_cart')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _darkNavy,
                                    foregroundColor: Colors.white,
                                    minimumSize: Size(0, context.h(55)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.w(15))),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    MockFirebase().addToCart(
                                      p,
                                      quantity: _quantity,
                                      size: _selectedSize,
                                      color: _selectedColor,
                                    );
                                    Navigator.pushNamed(context, CheckoutScreen.routeName);
                                  },
                                  icon: HugeIcon(icon: HugeIcons.strokeRoundedShoppingBag01, color: Colors.black, size: 24.0),
                                  label: Text(Translator.t('buy_now')),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _salmon,
                                    foregroundColor: Colors.white,
                                    minimumSize: Size(0, context.h(55)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.w(15))),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 30),

                          _buildExpandableTile(
                            Translator.t('product_details'), 
                            onTap: () => Navigator.pushNamed(
                              context, 
                              ProductInfoScreen.routeName, 
                              arguments: p
                            )
                          ),
                          const Divider(),
                          _buildExpandableTile(
                            Translator.t('specifications'), 
                            subtitle: p['description']?.toString(),
                            onTap: () => Navigator.pushNamed(
                              context, 
                              ProductInfoScreen.routeName, 
                              arguments: p
                            )
                          ),
                          
                          const SizedBox(height: 40),

                          _buildReviewsSection(p['id'].toString()),

                          SizedBox(height: context.h(40)),

                          Text(Translator.t('similar_products'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(18))),
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
      },
    );
  }

  Widget _buildCircleButton({required dynamic icon, Color? color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.w(8)),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: HugeIcon(icon: icon, color: color ?? Colors.black, size: context.w(24)),
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
          IconButton(onPressed: _decrement, icon: HugeIcon(icon: HugeIcons.strokeRoundedRemove01, size: context.w(18), color: Colors.black)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: context.w(12)),
            child: Text('$_quantity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(16))),
          ),
          IconButton(onPressed: _increment, icon: HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: context.w(18), color: Colors.black)),
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
                      fontSize: context.sp(14),
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
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(16))),
                  if (subtitle != null) ...[
                    SizedBox(height: context.h(8)),
                    Text(
                      subtitle, 
                      style: TextStyle(color: Colors.grey[600], fontSize: context.sp(14)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ]
                ],
              ),
            ),
            HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: Colors.black, size: context.w(24)),
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
                Text(Translator.t('reviews'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, ReviewsScreen.routeName, arguments: widget.product),
                  child: Text(Translator.t('view_all'), style: const TextStyle(color: _salmon, fontWeight: FontWeight.bold)),
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
                      children: List.generate(5, (i) => HugeIcon(icon: HugeIcons.strokeRoundedStars, color: i < (r['rating'] ?? 0) ? Colors.amber : Colors.grey[300], 
                        size: 12,)),
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
                  SnackBar(content: Text(Translator.t('added_to_cart')), duration: const Duration(seconds: 1)),
                );
              },
            );
          },
        );
      },
    );
  }
  Widget _buildCartShortcut(BuildContext context, Map<String, dynamic> p) {
    return Container(
      decoration: BoxDecoration(
        color: _salmon.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: HugeIcon(icon: HugeIcons.strokeRoundedShoppingCartAdd01, color: _salmon, size: 20),
        onPressed: () {
          MockFirebase().addToCart(p, size: _selectedSize, color: _selectedColor, quantity: _quantity);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Translator.t('added_to_cart')), 
              duration: const Duration(seconds: 1),
              backgroundColor: _darkNavy,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      ),
    );
  }
}
