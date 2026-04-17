import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../backend/mock_firebase.dart';
import '../../backend/translator.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  static const String routeName = '/language';

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  List<String> _allLanguages = [];
  List<String> _filteredLanguages = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Predefined top languages for better UX
  final List<String> _topLanguages = ['English', 'Français', 'Español', 'Deutsch', 'Arabic', 'Portuguese', 'Swahili'];

  @override
  void initState() {
    super.initState();
    _fetchLanguages();
    _searchController.addListener(_filterLanguages);
  }

  Future<void> _fetchLanguages() async {
    try {
      final response = await http.get(
        Uri.parse('https://restcountries.com/v3.1/all?fields=languages'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Set<String> uniqueLangs = {};
        
        // Add top languages first
        uniqueLangs.addAll(_topLanguages);

        for (var country in data) {
          final langs = country['languages'] as Map<String, dynamic>?;
          if (langs != null) {
            langs.forEach((code, name) {
              uniqueLangs.add(name as String);
            });
          }
        }
        
        final sortedLangs = uniqueLangs.toList()..sort();
        
        if (mounted) {
          setState(() {
            _allLanguages = sortedLangs;
            _filteredLanguages = sortedLangs;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load languages');
      }
    } catch (e) {
      debugPrint('Error fetching languages: $e');
      if (mounted) {
        setState(() {
          _allLanguages = _topLanguages;
          _filteredLanguages = _topLanguages;
          _isLoading = false;
          // We show top languages as fallback instead of error
        });
      }
    }
  }

  void _filterLanguages() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLanguages = _allLanguages.where((lang) {
        return lang.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _updateLanguage(String language) async {
    final user = MockFirebase().currentUser;
    if (user == null) return;

    final preferences = Map<String, dynamic>.from(user['preferences'] ?? {});
    preferences['language'] = language;

    await MockFirebase().updateUser(user['id'], {'preferences': preferences});
    
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${Translator.t('update_success')} : $language', 
            style: const TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFFFF8C8C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(Translator.t('select_language'), 
          style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      body: AnimatedBuilder(
        animation: MockFirebase(),
        builder: (context, _) {
          final user = MockFirebase().currentUser;
          final selectedLanguage = user?['preferences']?['language'] ?? 'English';

          return Column(
            children: [
              // --- PROMINENT CURRENT SELECTION ---
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8C8C), Color(0xFFFFB3B3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8C8C).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.language, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${Translator.t('language')} / Active Language', 
                            style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(selectedLanguage, 
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle, color: Colors.white, size: 28),
                  ],
                ),
              ),

              // --- SEARCH BAR ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: Translator.t('search_language'),
                    prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty 
                      ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => _searchController.clear())
                      : null,
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16), 
                      borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1))
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16), 
                      borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1))
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16), 
                      borderSide: const BorderSide(color: Color(0xFFFF8C8C), width: 1)
                    ),
                  ),
                ),
              ),

              // --- LIST ---
              Expanded(
                child: _isLoading 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8C8C))),
                          const SizedBox(height: 16),
                          Text(Translator.t('loading')),
                        ],
                      ),
                    )
                  : _filteredLanguages.isEmpty
                    ? Center(child: Text(Translator.t('retry')))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredLanguages.length,
                        itemBuilder: (context, index) {
                          final lang = _filteredLanguages[index];
                          final isSelected = selectedLanguage == lang;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color: isSelected ? const Color(0xFFFFF5F5) : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                onTap: () => _updateLanguage(lang),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected 
                                        ? const Color(0xFFFF8C8C).withValues(alpha: 0.3) 
                                        : Colors.grey.withValues(alpha: 0.05)
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFFFF8C8C).withValues(alpha: 0.1) : Colors.grey[50],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(lang.substring(0, 1).toUpperCase(), 
                                            style: TextStyle(
                                              color: isSelected ? const Color(0xFFFF8C8C) : Colors.grey[400],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            )),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(lang, 
                                          style: TextStyle(
                                            color: isSelected ? const Color(0xFFFF8C8C) : Colors.black87,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            fontSize: 16,
                                          )),
                                      ),
                                      if (isSelected) 
                                        const Icon(Icons.check_circle, color: Color(0xFFFF8C8C), size: 22),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
