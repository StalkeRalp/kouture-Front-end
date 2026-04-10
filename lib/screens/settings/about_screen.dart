import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String routeName = '/about';
  static const Color _salmon = Color(0xFFFF8C8C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('À propos', 
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: _salmon.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Text('K', style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: _salmon, fontFamily: 'Serif')),
              ),
              const SizedBox(height: 20),
              const Text('Kouture', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D0D26))),
              const SizedBox(height: 8),
              Text('Version 1.0.4 Premium', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
              const SizedBox(height: 40),
              const Text(
                'Kouture est la destination ultime pour la mode africaine haut de gamme. Nous connectons les meilleurs artisans et créateurs avec une audience globale, en mettant l\'accent sur la qualité et le sur-mesure.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
              ),
              const SizedBox(height: 50),
              const Divider(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialIcon(Icons.facebook),
                  _buildSocialIcon(Icons.camera_alt),
                  _buildSocialIcon(Icons.language),
                ],
              ),
              const SizedBox(height: 40),
              Text('© 2026 Kouture Marketplace. Tous droits réservés.', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Icon(icon, color: Colors.grey[600], size: 20),
      ),
    );
  }
}
