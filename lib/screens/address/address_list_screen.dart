import 'package:flutter/material.dart';

/// Gérer adresses de livraison
/// Principe SRP : une seule responsabilité par écran.
class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key});

  static const String routeName = '/addresses';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AddressListScreen')),
      body: const Center(child: Text('AddressListScreen - TODO')),
    );
  }
}
