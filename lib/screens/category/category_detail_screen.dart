import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import '../../backend/translator.dart';
import '../../widgets/product_card.dart';

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({super.key});

  static const String routeName = '/category-detail';

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  static const Color _navy = Color(0xFF0D0D26);
  static const Color _rose = Color(0xFFFF8C8C);
  
  List<dynamic> _products = [];
  bool _isLoading = true;
  String _categoryId = '';
  String _categoryName = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _categoryId.isEmpty) {
      _categoryId = args['categoryId'] ?? '';
      _categoryName = args['categoryName'] ?? '';
      _loadProducts();
    }
  }

  Future<void> _loadProducts() async {
    final products = await MockFirebase().getProductsByCategoryId(_categoryId);
    if (mounted) {
      setState(() {
        _products = products;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Translate title if possible
    final translatedTitle = Translator.t(_categoryName.toLowerCase().replaceAll(' ', '_'));

    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: Text(
              translatedTitle == _categoryName.toLowerCase().replaceAll(' ', '_') 
                  ? _categoryName // Fallback to original name if no dict match
                  : translatedTitle,
              style: const TextStyle(
                color: _navy,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            iconTheme: const IconThemeData(color: _navy),
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: _rose),
                )
              : _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.style_outlined, size: 80, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            Translator.t('no_products_found'),
                            style: const TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return ProductCard(product: product);
                        },
                      ),
                    ),
        );
      },
    );
  }
}
