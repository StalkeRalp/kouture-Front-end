import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  static const String routeName = '/search';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  static const Color _salmon = Color(0xFFFF8C8C);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _onSearch(String query) {
    if (query.trim().isEmpty) return;
    MockFirebase().addSearchQuery(query);
    Navigator.pushNamed(context, SearchResultsScreen.routeName, arguments: query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onSubmitted: _onSearch,
          decoration: InputDecoration(
            hintText: 'Rechercher un produit...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: InputBorder.none,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => _searchController.clear(),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: MockFirebase(),
        builder: (context, _) {
          final recent = MockFirebase().recentSearches;
          
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              if (recent.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recherches récentes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton(
                      onPressed: () => MockFirebase().clearRecentSearches(),
                      child: const Text('Tout effacer', style: TextStyle(color: _salmon, fontSize: 13)),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: recent.map((query) => GestureDetector(
                    onTap: () {
                      _searchController.text = query;
                      _onSearch(query);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(query, style: TextStyle(color: Colors.grey[800])),
                        ],
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 30),
              ],
              
              const Text('Tags populaires', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 15),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ['Ankara', 'Bazin', 'Wax', 'Streetwear', 'Mariage', 'Traditionnel', 'Custom'].map((tag) => GestureDetector(
                  onTap: () {
                    _searchController.text = tag;
                    _onSearch(tag);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[200]!),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(tag, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                )).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
