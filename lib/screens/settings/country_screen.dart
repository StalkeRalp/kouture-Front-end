import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../backend/mock_firebase.dart';
import '../../backend/translator.dart';
import 'package:hugeicons/hugeicons.dart';

class CountryScreen extends StatefulWidget {
  const CountryScreen({super.key});

  static const String routeName = '/country';

  @override
  State<CountryScreen> createState() => _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _allCountries = [];
  List<Map<String, dynamic>> _filteredCountries = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCountries();
    _searchController.addListener(_filterCountries);
  }

  Future<void> _fetchCountries() async {
    try {
      final response = await http.get(
        Uri.parse('https://restcountries.com/v3.1/all?fields=name,flags,region'),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception(Translator.t('connection_too_slow')),
      );

      if (response.statusCode == 200) {
        final List<dynamic> countriesData = json.decode(response.body);
        
        final List<Map<String, dynamic>> africanCountries = countriesData
            .where((country) => country['region'] == 'Africa')
            .map((country) => {
              'name': country['name']['common'] as String,
              'flag': country['flags']['png'] as String,
            })
            .toList();
            
        africanCountries.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
        
        if (mounted) {
          setState(() {
            _allCountries = africanCountries;
            _filteredCountries = africanCountries;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Erreur lors du chargement des pays');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = Translator.t('loading_error');
          _isLoading = false;
        });
      }
    }
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCountries = _allCountries.where((country) {
        return (country['name'] as String).toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _updateCountry(String country) async {
    final user = MockFirebase().currentUser;
    if (user == null) return;

    final preferences = Map<String, dynamic>.from(user['preferences'] ?? {});
    preferences['country'] = country;

    await MockFirebase().updateUser(user['id'], {'preferences': preferences});

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${Translator.t('country_updated')} : $country', 
            style: const TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: const Color(0xFFFF8C8C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
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
        title: Text(Translator.t('select_country'),
          style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: Colors.black87, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8C8C)),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(Translator.t('loading_african_countries'), 
                    style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            shape: BoxShape.circle,
                          ),
                          child: HugeIcon(icon: HugeIcons.strokeRoundedCloudOff, size: 48, color: Colors.grey[300]),
                        ),
                        const SizedBox(height: 24),
                        Text(_errorMessage!, 
                          textAlign: TextAlign.center, 
                          style: const TextStyle(color: Colors.black54, fontSize: 14, height: 1.5)),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() { _isLoading = true; _errorMessage = null; });
                              _fetchCountries();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8C8C),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: const Text('Réessayer', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : AnimatedBuilder(
                  animation: MockFirebase(),
                  builder: (context, _) {
                    final user = MockFirebase().currentUser;
                    final selectedCountry = user?['preferences']?['country'] ?? '';

                    return Column(
                      children: [
                        // --- PROMINENT SELECTED COUNTRY DISPLAY ---
                        if (selectedCountry.isNotEmpty)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFFF8C8C),
                                  const Color(0xFFFF8C8C).withValues(alpha: 0.8),
                                ],
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
                                  child: HugeIcon(icon: HugeIcons.strokeRoundedGlobe, color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(Translator.t('your_current_country'), 
                                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                                      const SizedBox(height: 4),
                                      Text(selectedCountry, 
                                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkBadge01, color: Colors.white, size: 24),
                              ],
                            ),
                          ),

                        // --- SEARCH BAR ---
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: Translator.t('search_country_hint'),
                              prefixIcon: HugeIcon(icon: HugeIcons.strokeRoundedSearch01, size: 20, color: Colors.grey),
                              suffixIcon: _searchController.text.isNotEmpty 
                                ? IconButton(
                                    icon: HugeIcon(icon: HugeIcons.strokeRoundedCancel01, size: 18, color: Colors.grey), 
                                    onPressed: () => _searchController.clear()
                                  )
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
                          child: _filteredCountries.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      HugeIcon(icon: HugeIcons.strokeRoundedSearchRemove, size: 64, color: Colors.grey[200]),
                                      const SizedBox(height: 16),
                                      Text(Translator.t('no_country_found'), 
                                        style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: _filteredCountries.length,
                                  itemBuilder: (context, index) {
                                    final countryData = _filteredCountries[index];
                                    final countryName = countryData['name'] as String;
                                    final countryFlag = countryData['flag'] as String;
                                    final isSelected = selectedCountry == countryName;

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Material(
                                        color: isSelected ? const Color(0xFFFFF5F5) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
                                        child: InkWell(
                                          onTap: () => _updateCountry(countryName),
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
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(4),
                                                  child: Image.network(
                                                    countryFlag,
                                                    width: 32,
                                                    height: 22,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) => HugeIcon(icon: HugeIcons.strokeRoundedFlag01, size: 24, color: Colors.grey),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(countryName, 
                                                    style: TextStyle(
                                                      color: isSelected ? const Color(0xFFFF8C8C) : Colors.black87,
                                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                      fontSize: 15,
                                                    )),
                                                ),
                                                if (isSelected) 
                                                  HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkCircle01, color: Color(0xFFFF8C8C), size: 20),
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