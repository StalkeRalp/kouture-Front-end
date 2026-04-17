import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../backend/mock_firebase.dart';
import '../../backend/translator.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  static const String routeName = '/currency';

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String? _nativeCurrency;
  String? _nativeFlag;
  bool _isLoadingNative = true;

  final List<Map<String, String>> _standardCurrencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar', 'flag': '🇺🇸'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro', 'flag': '🇪🇺'},
    {'code': 'XAF', 'symbol': 'FCFA', 'name': 'Franc CFA (BEAC)', 'flag': '🇨🇲'},
    {'code': 'XOF', 'symbol': 'FCFA', 'name': 'Franc CFA (BCEAO)', 'flag': '🇸🇳'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound', 'flag': '🇬🇧'},
    {'code': 'NGN', 'symbol': '₦', 'name': 'Nigerian Naira', 'flag': '🇳🇬'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchNativeCurrency();
  }

  Future<void> _fetchNativeCurrency() async {
    final user = MockFirebase().currentUser;
    final countryName = user?['preferences']?['country'];

    if (countryName == null || countryName.isEmpty) {
      if (mounted) setState(() => _isLoadingNative = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://restcountries.com/v3.1/name/${Uri.encodeComponent(countryName)}?fullText=true&fields=currencies,flags'),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final currenciesMap = data[0]['currencies'] as Map<String, dynamic>;
          final firstCurrencyCode = currenciesMap.keys.first;
          final currencyInfo = currenciesMap[firstCurrencyCode];
          
          if (mounted) {
            setState(() {
              _nativeCurrency = '$firstCurrencyCode ${currencyInfo['symbol'] ?? ''}';
              _nativeFlag = data[0]['flags']['png'];
              _isLoadingNative = false;
            });
          }
        }
      } else {
        if (mounted) setState(() => _isLoadingNative = false);
      }
    } catch (e) {
      debugPrint('Error fetching native currency: $e');
      if (mounted) setState(() => _isLoadingNative = false);
    }
  }

  Future<void> _updateCurrency(String currency) async {
    final user = MockFirebase().currentUser;
    if (user == null) return;

    final preferences = Map<String, dynamic>.from(user['preferences'] ?? {});
    preferences['currency'] = currency;

    await MockFirebase().updateUser(user['id'], {'preferences': preferences});

    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${Translator.t('currency_updated')} : $currency', 
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(Translator.t('select_currency'),
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
          final selectedCurrency = user?['preferences']?['currency'] ?? 'XAF 🇨🇲';

          return CustomScrollView(
            slivers: [
              // --- NATIVE CURRENCY SUGGESTION ---
              if (_isLoadingNative)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF8C8C)),
                      ),
                    ),
                  ),
                )
              else if (_nativeCurrency != null)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(Translator.t('suggested_for_country')),
                      _buildCurrencyItem(
                        _nativeCurrency!, 
                        isNative: true, 
                        flagUrl: _nativeFlag,
                        isSelected: selectedCurrency.contains(_nativeCurrency!.split(' ')[0]),
                        onTap: () => _updateCurrency(_nativeCurrency!),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

              // --- STANDARD CURRENCIES ---
              SliverToBoxAdapter(
                child: _buildHeader(Translator.t('all_currencies')),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final curr = _standardCurrencies[index];
                    final display = '${curr['code']} ${curr['symbol']}';
                    final isSelected = selectedCurrency.contains(curr['code']!);

                    return _buildCurrencyItem(
                      display,
                      subtitle: curr['name'],
                      flagEmoji: curr['flag'],
                      isSelected: isSelected,
                      onTap: () => _updateCurrency(display),
                    );
                  },
                  childCount: _standardCurrencies.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCurrencyItem(
    String title, {
    bool isNative = false,
    String? flagUrl,
    String? flagEmoji,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: isSelected ? const Color(0xFFFFF5F5) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isNative ? const Color(0xFFFF8C8C).withValues(alpha: 0.1) : Colors.grey[50],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: flagUrl != null
                      ? ClipOval(
                          child: Image.network(flagUrl, width: 28, height: 28, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.money)))
                      : Text(flagEmoji ?? '💰', style: const TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, 
                        style: TextStyle(
                          color: isSelected ? const Color(0xFFFF8C8C) : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                      if (subtitle != null)
                        Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Color(0xFFFF8C8C), size: 24)
                else
                  Icon(Icons.radio_button_off, color: Colors.grey[300], size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
