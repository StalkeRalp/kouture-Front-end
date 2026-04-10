import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const String routeName = '/help';
  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _darkNavy = Color(0xFF0D0D26);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Aide & Support', 
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text('Comment pouvons-nous vous aider ?', 
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _darkNavy)),
          const SizedBox(height: 30),
          _buildFaqItem('Comment suivre ma commande ?', 'Allez dans l\'onglet "Activités" pour voir le suivi en temps réel de votre colis.'),
          _buildFaqItem('Quels sont les modes de paiement ?', 'Nous acceptons Orange Money, MTN Mobile Money et les Cartes Bancaires (Visa/Mastercard).'),
          _buildFaqItem('Puis-je retourner un article ?', 'Oui, les retours sont acceptés sous 7 jours si l\'article n\'a pas été porté et que le sceau de garantie est intact.'),
          _buildFaqItem('Délais de confection ?', 'La plupart de nos créateurs confectionnent vos tenues en 5 à 10 jours ouvrés.'),
          const SizedBox(height: 40),
          const Text('Besoin de parler à un expert ?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _darkNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(vertical: 20),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 20),
                SizedBox(width: 12),
                Text('CONTACTER LE SUPPORT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),
          ),
          const SizedBox(height: 15),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _salmon),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              padding: const EdgeInsets.symmetric(vertical: 20),
            ),
            child: const Text('ENVOYER UN EMAIL', style: TextStyle(color: _salmon, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _darkNavy)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: _salmon,
        collapsedIconColor: Colors.grey,
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        children: [
          Text(answer, style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
