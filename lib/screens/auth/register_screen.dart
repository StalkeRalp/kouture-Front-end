import 'package:flutter/material.dart';

/// Inscription utilisateur
/// Principe SRP : une seule responsabilité par écran.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static const String routeName = '/register';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RegisterScreen')),
      body: const Center(child: Text('RegisterScreen - TODO')),
    );
  }
}
