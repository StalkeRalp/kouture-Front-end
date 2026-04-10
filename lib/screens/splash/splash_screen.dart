import 'package:flutter/material.dart';

/// Écran de démarrage
/// Principe SRP : une seule responsabilité par écran.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const String routeName = '/splash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SplashScreen')),
      body: const Center(child: Text('SplashScreen - TODO')),
    );
  }
}
