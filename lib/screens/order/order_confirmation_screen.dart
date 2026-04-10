import 'package:flutter/material.dart';

/// Confirmation de commande
/// Principe SRP : une seule responsabilité par écran.
class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  static const String routeName = '/order-confirmation';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OrderConfirmationScreen')),
      body: const Center(child: Text('OrderConfirmationScreen - TODO')),
    );
  }
}
