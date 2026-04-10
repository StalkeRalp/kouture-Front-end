import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../backend/mock_firebase.dart';

class CountryScreen extends StatefulWidget {
  const CountryScreen({super.key});

  static const String routeName = '/country';

  @override
  State<CountryScreen> createState() => _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  List<String> _allCountries = [];
  List<String> _filteredCountries = [];
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
        Uri.parse('https://restcountries.com/v3.1/all'),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connexion trop lente'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> countriesData = json.decode(response.body);
        
        final List<String> africanCountries = countriesData
            .where((country) => country['region'] == 'Africa')
            .map((country) => country['name']['common'] as String)
            .toList()
          ..sort();
        
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
          _errorMessage = 'Impossible de charger la liste des pays. Vérifiez votre connexion.';
          _isLoading = false;
        });
      }
    }
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCountries = _allCountries.where((country) {
        return country.toLowerCase().contains(query);
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
          content: Text('Pays mis à jour : $country', 
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
        title: const Text('Sélectionner le pays',
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
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8C8C))),
                  SizedBox(height: 16),
                  Text('Chargement...', style: TextStyle(color: Colors.black54)),
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
                        Icon(Icons.cloud_off, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 24),
                        OutlinedButton(
                          onPressed: () {
                            setState(() { _isLoading = true; _errorMessage = null; });
                            _fetchCountries();
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFF8C8C)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Réessayer', style: TextStyle(color: Color(0xFFFF8C8C))),
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
                              color: const Color(0xFFFFF5F5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFFF8C8C).withOpacity(0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF8C8C).withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.public, color: Color(0xFFFF8C8C), size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Pays Sélectionné', 
                                        style: TextStyle(color: Colors.black.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                                      const SizedBox(height: 4),
                                      Text(selectedCountry, 
                                        style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.check_circle, color: Color(0xFFFF8C8C), size: 28),
                              ],
                            ),
                          ),

                        // --- SEARCH BAR ---
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Rechercher par nom...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: _searchController.text.isNotEmpty 
                                ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => _searchController.clear())
                                : null,
                              filled: true,
                              fillColor: Colors.grey.withOpacity(0.08),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
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
                                      Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
                                      const SizedBox(height: 12),
                                      Text('Aucun résultat pour "${_searchController.text}"', style: TextStyle(color: Colors.grey[400])),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  itemCount: _filteredCountries.length,
                                  itemBuilder: (context, index) {
                                    final country = _filteredCountries[index];
                                    final isSelected = selectedCountry == country;

                                    return InkWell(
                                      onTap: () => _updateCountry(country),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                        decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.05))),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(country, 
                                                style: TextStyle(
                                                  color: isSelected ? const Color(0xFFFF8C8C) : Colors.black87,
                                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                  fontSize: 15,
                                                )),
                                            ),
                                            if (isSelected) 
                                              const Icon(Icons.check, color: Color(0xFFFF8C8C), size: 18),
                                          ],
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