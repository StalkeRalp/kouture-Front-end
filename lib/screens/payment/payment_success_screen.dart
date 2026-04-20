import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import '../../backend/translator.dart';
import '../order/order_confirmation_screen.dart';
import 'package:hugeicons/hugeicons.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  static const String routeName = '/payment-success';

  @override
  Widget build(BuildContext context) {
    const Color salmon = Color(0xFFFF8C8C);
    
    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkCircle01, size: 80, color: Colors.green),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    Translator.t('order_success'),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D0D26)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Translator.t('order_success_desc'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16, height: 1.5),
                  ),
                  const Spacer(),
                  _buildActionButton(
                    label: Translator.t('view_my_order'),
                    onPressed: () => Navigator.pushReplacementNamed(context, OrderConfirmationScreen.routeName),
                    color: const Color(0xFF0D0D26),
                  ),
                  const SizedBox(height: 15),
                  _buildActionButton(
                    label: Translator.t('return_home'),
                    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                    color: salmon,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({required String label, required VoidCallback onPressed, required Color color}) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
