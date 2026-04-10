import 'package:flutter/material.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  static const String routeName = '/currency';

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String _selectedCurrency = 'XAF 🇨🇲';

  final List<String> _currencies = [
    'XAF 🇨🇲',
    'EUR 🇪🇺',
    'USD 🇺🇸',
    'CAD 🇨🇦',
    'GBP 🇬🇧',
    'NGN 🇳🇬',
    'GHS 🇬🇭',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Devise', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: _currencies.length,
        itemBuilder: (context, index) {
          return _buildCurrencyOption(_currencies[index]);
        },
      ),
    );
  }

  Widget _buildCurrencyOption(String currency) {
    return RadioListTile<String>(
      title: Text(currency, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
      value: currency,
      groupValue: _selectedCurrency,
      activeColor: const Color(0xFFFF8C8C),
      onChanged: (value) {
        setState(() {
          _selectedCurrency = value!;
        });
      },
    );
  }
}
