import 'package:flutter/material.dart';

/// Liste des catégories
/// Principe SRP : une seule responsabilité par écran.
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  static const String routeName = '/categories';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CategoryScreen')),
      body: const Center(child: Text('CategoryScreen - TODO')),
    );
  }
}
