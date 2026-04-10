import 'package:flutter/material.dart';

/// Ajouter une adresse
/// Principe SRP : une seule responsabilité par écran.
class AddAddressScreen extends StatelessWidget {
  const AddAddressScreen({super.key});

  static const String routeName = '/add-address';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AddAddressScreen')),
      body: const Center(child: Text('AddAddressScreen - TODO')),
    );
  }
}
