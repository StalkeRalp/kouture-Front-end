import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  static const String routeName = '/language';

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final Map<String, String> _languages = {
    'English': 'English',
    'Français': 'French',
    'Español': 'Spanish',
    'Deutsch': 'German',
  };

  Future<void> _updateLanguage(String language) async {
    final user = MockFirebase().currentUser;
    if (user == null) return;

    final preferences = Map<String, dynamic>.from(user['preferences'] ?? {});
    preferences['language'] = language;

    await MockFirebase().updateUser(user['id'], {'preferences': preferences});
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Langue mise à jour : $language'),
          backgroundColor: const Color(0xFFFF8C8C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Langue', 
          style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
        ),
      ),
      body: AnimatedBuilder(
        animation: MockFirebase(),
        builder: (context, _) {
          final user = MockFirebase().currentUser;
          final selectedLanguage = user?['preferences']?['language'] ?? 'English';

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: _languages.keys.map((lang) {
              final isSelected = selectedLanguage == lang;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFF5F5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(lang, 
                    style: TextStyle(
                      color: isSelected ? const Color(0xFFFF8C8C) : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    )),
                  trailing: isSelected 
                    ? const Icon(Icons.check_circle, color: Color(0xFFFF8C8C))
                    : null,
                  onTap: () => _updateLanguage(lang),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
