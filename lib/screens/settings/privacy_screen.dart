import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import '../../backend/translator.dart';
import 'package:hugeicons/hugeicons.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const String routeName = '/privacy';
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
            title: Text(Translator.t('privacy'), 
              style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: Colors.black, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Translator.t('privacy_policy'), 
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _darkNavy)),
                const SizedBox(height: 10),
                Text('${Translator.t('last_update')} : Avril 2026', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                const SizedBox(height: 30),
                _buildSection(Translator.t('privacy_section1_title'), 
                  Translator.t('privacy_section1_content')),
                _buildSection(Translator.t('privacy_section2_title'), 
                  Translator.t('privacy_section2_content')),
                _buildSection(Translator.t('privacy_section3_title'), 
                  Translator.t('privacy_section3_content')),
                _buildSection(Translator.t('privacy_section4_title'), 
                  Translator.t('privacy_section4_content')),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _salmon.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: _salmon.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      HugeIcon(icon: HugeIcons.strokeRoundedInformationCircle, color: _salmon, size: 24.0),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          Translator.t('privacy_footer'),
                          style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
