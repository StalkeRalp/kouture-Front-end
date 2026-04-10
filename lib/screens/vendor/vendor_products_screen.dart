import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import '../../widgets/product_card.dart';

class VendorProductsScreen extends StatelessWidget {
  const VendorProductsScreen({super.key});

  static const String routeName = '/vendor-products';

  @override
  Widget build(BuildContext context) {
    final String vendorId = ModalRoute.of(context)?.settings.arguments as String? ?? 'v1';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Produits du Vendeur', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        // We'll need to add getProductsByVendor to MockFirebase
        future: MockFirebase().getProductsByVendor(vendorId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C8C)));
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(child: Text('Aucun produit trouvé pour ce vendeur.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.68,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          );
        },
      ),
    );
  }
}
