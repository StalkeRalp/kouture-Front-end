import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';

import '../../widgets/product_card.dart';
import 'filter_screen.dart';


class ProductSearchDelegate extends SearchDelegate<String> {
  static const Color _salmon = Color(0xFFFF8C8C);

  Map<String, dynamic>? _activeFilters;

  @override
  String get searchFieldLabel => 'What are you looking for...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.grey),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.grey),
          onPressed: () {
            query = '';
          },
        ),
      IconButton(
        icon: Icon(Icons.tune, color: (_activeFilters != null) ? _salmon : Colors.black),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FilterScreen(initialFilters: _activeFilters),
            ),
          );
          if (result != null) {
            _activeFilters = result as Map<String, dynamic>;
            if (!context.mounted) return;
            showResults(context); // Refresh results with new filters
          }
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isNotEmpty) {
      MockFirebase().addSearchQuery(query.trim());
    }

    final allProducts = MockFirebase().allProducts;
    final results = allProducts.where((p) {
      final name = p['name'].toString().toLowerCase();
      final category = p['category'].toString().toLowerCase();
      final search = query.toLowerCase();
      
      // Text Search
      bool matchesSearch = name.contains(search) || category.contains(search);
      if (!matchesSearch) return false;

      // Active Filters
      if (_activeFilters != null) {
        // Price Range
        final RangeValues range = _activeFilters!['priceRange'];
        final double price = (p['price'] as num).toDouble();
        if (price < range.start || price > range.end) return false;

        // Categories
        final List<String> selCats = _activeFilters!['categories'];
        if (selCats.isNotEmpty && !selCats.contains(p['category'])) return false;

        // Sizes
        final List<String> selSizes = _activeFilters!['sizes'];
        if (selSizes.isNotEmpty) {
          final List<dynamic> pSizes = p['sizes'] ?? [];
          bool hasSize = pSizes.any((s) => selSizes.contains(s.toString()));
          if (!hasSize) return false;
        }

        // Color
        final String? selColor = _activeFilters!['color'];
        if (selColor != null) {
          final List<dynamic> pColors = p['colors'] ?? [];
          if (!pColors.contains(selColor)) return false;
        }
      }

      return true;
    }).toList();

    if (results.isEmpty) {
      return const Center(child: Text('Aucun résultat trouvé.'));
    }

    return Container(
      color: const Color(0xFFF8F8F8), // Match light background of the app
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 30),
        itemCount: results.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 18,
          crossAxisSpacing: 14,
          childAspectRatio: 0.68,
        ),
        itemBuilder: (context, index) {
          final p = results[index] as Map<String, dynamic>;
          return ProductCard(
            product: p,
            onFavoriteTap: () {},
            onAddToCartTap: () {},
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) {
      // Show instant suggestions as they type
      final allProducts = MockFirebase().allProducts;
      final fastResults = allProducts.where((p) {
        final name = p['name'].toString().toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();

      return Container(
        color: const Color(0xFFF8F8F8),
        child: ListView.builder(
          itemCount: fastResults.length,
          itemBuilder: (context, index) {
            final p = fastResults[index];
            return ListTile(
              leading: const Icon(Icons.search, color: Colors.grey),
              title: Text(p['name'].toString()),
              onTap: () {
                query = p['name'].toString();
                showResults(context);
              },
            );
          },
        ),
      );
    }

    // Empty state: show recent searches
    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        final recents = MockFirebase().recentSearches;
        if (recents.isEmpty) {
          return Container(
            color: const Color(0xFFF8F8F8),
            child: const Center(
              child: Text(
                'Commencez à chercher...',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Container(
          color: const Color(0xFFF8F8F8),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Searches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton(
                    onPressed: () => MockFirebase().clearRecentSearches(),
                    child: const Text('Clear all', style: TextStyle(color: _salmon)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: recents.length,
                  itemBuilder: (context, index) {
                    final recent = recents[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.history, color: Colors.grey),
                      title: Text(recent, style: const TextStyle(color: Colors.black87)),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                        onPressed: () {
                          MockFirebase().removeRecentSearch(recent);
                        },
                      ),
                      onTap: () {
                        query = recent;
                        showResults(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
