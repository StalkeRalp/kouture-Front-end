import 'package:flutter/material.dart';

/// Introduction pour nouveaux utilisateurs
/// Principe SRP : une seule responsabilité par écran.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const String routeName = '/onboarding';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OnboardingScreen')),
      body: const Center(child: Text('OnboardingScreen - TODO')),
    );
  }
}
