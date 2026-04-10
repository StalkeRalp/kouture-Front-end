import 'package:flutter/material.dart';

/// Connexion utilisateur
/// Principe SRP : une seule responsabilité par écran.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LoginScreen')),
      body: const Center(child: Text('LoginScreen - TODO')),
    );
  }
}
