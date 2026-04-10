import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const String routeName = '/privacy';
  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _darkNavy = Color(0xFF0D0D26);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Confidentialité', 
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Politique de Confidentialité', 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _darkNavy)),
            const SizedBox(height: 10),
            Text('Dernière mise à jour : Avril 2026', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            const SizedBox(height: 30),
            _buildSection('1. Collecte des données', 
              'Kouture collecte des informations pour améliorer votre expérience : nom, email, historique de commandes et préférences de style.'),
            _buildSection('2. Utilisation des données', 
              'Vos données sont utilisées pour personnaliser vos recommandations, traiter vos commandes et vous informer des promotions.'),
            _buildSection('3. Sécurité', 
              'Nous utilisons des protocoles de sécurité de pointe pour protéger vos informations personnelles et transactions bancaires.'),
            _buildSection('4. Vos droits', 
              'Vous disposez d\'un droit d\'accès, de rectification et de suppression de vos données personnelles à tout moment.'),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _salmon.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _salmon.withOpacity(0.1)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: _salmon),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'Pour toute question, contactez notre délégué à la protection des données via le menu Aide.',
                      style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _darkNavy)),
          const SizedBox(height: 10),
          Text(content, style: TextStyle(fontSize: 15, height: 1.6, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
