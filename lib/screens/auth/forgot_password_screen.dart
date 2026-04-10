import 'package:flutter/material.dart';

/// Réinitialisation mot de passe
/// Principe SRP : une seule responsabilité par écran.
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  static const String routeName = '/forgot-password';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ForgotPasswordScreen')),
      body: const Center(child: Text('ForgotPasswordScreen - TODO')),
    );
  }
}
