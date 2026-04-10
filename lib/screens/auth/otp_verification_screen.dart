import 'package:flutter/material.dart';

/// Vérification OTP par SMS
/// Principe SRP : une seule responsabilité par écran.
class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  static const String routeName = '/otp-verification';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OtpVerificationScreen')),
      body: const Center(child: Text('OtpVerificationScreen - TODO')),
    );
  }
}
