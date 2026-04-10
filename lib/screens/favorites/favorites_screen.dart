import 'package:flutter/material.dart';
import '../../widgets/product_card.dart';
import '../../backend/mock_firebase.dart';
import 'favoritesTailor_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  static const String routeName = '/favorites';
  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _darkNavy = Color(0xFF0D0D26);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Mes Favoris', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: _salmon,
            labelColor: _salmon,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Produits'),
              Tab(text: 'Couturiers'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ProductFavoritesTab(),
            FavoritesTailorScreen(isTab: true),
          ],
        ),
      ),
    );
  }
}

class _ProductFavoritesTab extends StatelessWidget {
  const _ProductFavoritesTab();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        final favoriteProducts = MockFirebase()
            .allProducts
            .where((p) => MockFirebase().isFavorite(p['id'].toString()))
            .toList();

        if (favoriteProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_outline, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 20),
                const Text('Aucun produit favori.', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 10),
                Text('Explorez nos produits et ajoutez vos favoris !', 
                  style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/discover'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D0D26),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text('EXPLORER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favoriteProducts.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 18,
            crossAxisSpacing: 14,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, index) {
            return ProductCard(
              product: favoriteProducts[index],
              heroPrefix: 'favorites',
            );
          },
        );
      },
    );
  }
}
