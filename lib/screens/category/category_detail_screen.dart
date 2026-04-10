import 'package:flutter/material.dart';

/// Détail d'une catégorie
/// Principe SRP : une seule responsabilité par écran.
class CategoryDetailScreen extends StatelessWidget {
  const CategoryDetailScreen({super.key});

  static const String routeName = '/category-detail';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CategoryDetailScreen')),
      body: const Center(child: Text('CategoryDetailScreen - TODO')),
    );
  }
}
