import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import './payment_success_screen.dart';
import './payment_failure_screen.dart';
import 'dart:math';

class PaymentProcessingScreen extends StatefulWidget {
  const PaymentProcessingScreen({super.key});

  static const String routeName = '/payment-processing';

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 3));
    
    // Simulate success/failure (90% success)
    final isSuccess = Random().nextDouble() < 0.9;

    if (mounted) {
      if (isSuccess) {
        // Create order before clearing cart
        final items = MockFirebase().cartItems;
        final total = MockFirebase().cartTotal;
        await MockFirebase().createOrder(items, total);
        
        // Simple logic: clear cart on success
        MockFirebase().cartItems.clear();
        MockFirebase().notifyListeners();
        Navigator.pushReplacementNamed(context, PaymentSuccessScreen.routeName);
      } else {
        Navigator.pushReplacementNamed(context, PaymentFailureScreen.routeName);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8C8C)),
              strokeWidth: 6,
            ),
            const SizedBox(height: 40),
            const Text(
              'Traitement sécurisé...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D0D26)),
            ),
            const SizedBox(height: 10),
            Text(
              'Veuillez ne pas fermer l\'application.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
