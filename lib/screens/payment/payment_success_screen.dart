import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  static const String routeName = '/payment-success';

  @override
  Widget build(BuildContext context) {
    final Color salmon = const Color(0xFFFF8C8C);
    
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
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
              ),
              const SizedBox(height: 40),
              const Text(
                'Commande Réussie !',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D0D26)),
              ),
              const SizedBox(height: 16),
              Text(
                'Votre commande #KT-2026-88 a été enregistrée avec succès. Vous recevrez une notification très bientôt.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16, height: 1.5),
              ),
              const Spacer(),
              _buildActionButton(
                label: 'VOIR MA COMMANDE',
                onPressed: () => Navigator.pushReplacementNamed(context, '/orders'),
                color: const Color(0xFF0D0D26),
              ),
              const SizedBox(height: 15),
              _buildActionButton(
                label: 'RETOUR À L\'ACCUEIL',
                onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                color: salmon,
              ),
            ],
          ),
        ),
      ),
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
