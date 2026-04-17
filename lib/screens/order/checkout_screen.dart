import 'package:flutter/material.dart';
import '../../backend/translator.dart';
import '../../backend/mock_firebase.dart';
import '../address/address_list_screen.dart';
import '../payment/orange_money_screen.dart';
import '../payment/mobile_money_screen.dart';
import '../payment/card_payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  static const String routeName = '/checkout';

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _darkNavy = Color(0xFF0D0D26);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        final cartItems = MockFirebase().cartItems;
        final subtotal = MockFirebase().cartSubtotal;
        final shipping = MockFirebase().cartShipping;
        final total = MockFirebase().cartTotal;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(Translator.t('checkout_confirmation'), style: const TextStyle(fontWeight: FontWeight.bold)),
            leading: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: cartItems.isEmpty
              ? Center(child: Text(Translator.t('cart_empty')))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ─── RÉSUMÉ DES ARTICLES ───
                            _buildSectionTitle(Translator.t('articles')),
                            const SizedBox(height: 15),
                            ...cartItems.map((item) => _buildMiniProductItem(item)),
                            
                            const SizedBox(height: 30),
                            
                            // ─── ADRESSE DE LIVRAISON ───
                            _buildSectionTitle(Translator.t('shipping_address')),
                            const SizedBox(height: 15),
                            _buildAddressCard(),
                            
                            const SizedBox(height: 30),
                            
                            // ─── MOYENS DE PAIEMENT ───
                            _buildSectionTitle(Translator.t('payment_method')),
                            const SizedBox(height: 15),
                            _buildPaymentMethods(),
                            
                            const SizedBox(height: 30),
                            
                            // ─── RÉSUMÉ DES PRIX ───
                            _buildSectionTitle(Translator.t('payment_details')),
                            const SizedBox(height: 15),
                            _buildPriceSummary(subtotal, shipping, total),
                          ],
                        ),
                      ),
                    ),
                    
                    // ─── BOUTON PAYER ───
                    _buildBottomAction(total),
                  ],
                ),
        );
      },
    );
  }

  int _selectedMethod = 0; // 0: Orange, 1: MoMo, 2: Card

  Widget _buildPaymentMethods() {
    final methods = [
      {'id': 0, 'name': 'Orange Money', 'icon': Icons.phone_android, 'color': Colors.orange},
      {'id': 1, 'name': 'MTN MoMo', 'icon': Icons.smartphone, 'color': Colors.yellow[700]},
      {'id': 2, 'name': Translator.t('credit_card'), 'icon': Icons.credit_card, 'color': Colors.blue},
    ];

    return Column(
      children: methods.map((m) {
        final isSelected = _selectedMethod == m['id'];
        return GestureDetector(
          onTap: () => setState(() => _selectedMethod = m['id'] as int),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? _salmon.withValues(alpha: 0.1) : Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isSelected ? _salmon : Colors.grey[200]!, width: isSelected ? 2 : 1),
            ),
            child: Row(
              children: [
                Icon(m['icon'] as IconData, color: m['color'] as Color),
                const SizedBox(width: 15),
                Text(m['name'] as String, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
                const Spacer(),
                if (isSelected) const Icon(Icons.check_circle, color: _darkNavy, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  bool get isBold => true; // Helper for types

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  Widget _buildMiniProductItem(Map<String, dynamic> item) {
    final p = item['product'];
    final images = p['images'] as List? ?? [];
    final img = images.isNotEmpty ? images[0] : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(img, width: 50, height: 50, fit: BoxFit.cover),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('${Translator.t('quantity')}: ${item['quantity']} • ${Translator.t('size')}: ${item['size']}', 
                  style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Text('${(p['price'] * item['quantity']).toStringAsFixed(0)} XAF', 
            style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    final user = MockFirebase().currentUser;
    final address = user?['address'] as Map<String, dynamic>? ?? {};
    final street = address['street'] ?? '123 Rue du Commerce';
    final city = address['city'] ?? 'Yaoundé';
    final country = address['country'] ?? 'Cameroun';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, color: _darkNavy),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(street, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$city, $country', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          TextButton(onPressed: () => Navigator.pushNamed(context, AddressListScreen.routeName), child: Text(Translator.t('edit'), style: const TextStyle(color: _darkNavy))),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(double subtotal, double shipping, double total) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _darkNavy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildPriceRow(Translator.t('subtotal'), '$subtotal XAF', Colors.white70),
          const SizedBox(height: 10),
          _buildPriceRow(Translator.t('shipping'), '$shipping XAF', Colors.white70),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(color: Colors.white24),
          ),
          _buildPriceRow(Translator.t('total'), '$total XAF', Colors.white, isBold: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(color: color, fontSize: isBold ? 18 : 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBottomAction(double total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: () {
            String route = '';
            switch (_selectedMethod) {
              case 0: route = OrangeMoneyScreen.routeName; break;
              case 1: route = MobileMoneyScreen.routeName; break;
              case 2: route = CardPaymentScreen.routeName; break;
            }
            Navigator.pushNamed(context, route);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: _darkNavy,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${Translator.t('pay')} ${total.toStringAsFixed(0)} XAF', 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              const SizedBox(width: 10),
              const Icon(Icons.security, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
