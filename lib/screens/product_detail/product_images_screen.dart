import 'package:flutter/material.dart';

/// Galerie images produit
/// Principe SRP : une seule responsabilité par écran.
class ProductImagesScreen extends StatelessWidget {
  const ProductImagesScreen({super.key});

  static const String routeName = '/product-images';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ProductImagesScreen')),
      body: const Center(child: Text('ProductImagesScreen - TODO')),
    );
  }
}
