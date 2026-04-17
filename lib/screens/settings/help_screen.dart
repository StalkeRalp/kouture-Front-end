import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import '../../backend/translator.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const String routeName = '/help';
  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _darkNavy = Color(0xFF0D0D26);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(Translator.t('help_support'), 
              style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
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
              Text(Translator.t('help_main_question'), 
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _darkNavy)),
              const SizedBox(height: 30),
              _buildFaqItem(Translator.t('faq_q1'), Translator.t('faq_a1')),
              _buildFaqItem(Translator.t('faq_q2'), Translator.t('faq_a2')),
              _buildFaqItem(Translator.t('faq_q3'), Translator.t('faq_a3')),
              _buildFaqItem(Translator.t('faq_q4'), Translator.t('faq_a4')),
              const SizedBox(height: 40),
              Text(Translator.t('help_expert_title'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble_outline, size: 20),
                    const SizedBox(width: 12),
                    Text(Translator.t('contact_support'), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                child: Text(Translator.t('send_email'), style: const TextStyle(color: _salmon, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ],
          ),
        );
      },
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
