import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';

class CartSummaryScreen extends StatefulWidget {
  const CartSummaryScreen({super.key});

  static const String routeName = '/cart-summary';

  @override
  State<CartSummaryScreen> createState() => _CartSummaryScreenState();
}

class _CartSummaryScreenState extends State<CartSummaryScreen> {
  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _darkNavy = Color(0xFF0D0D26);
  static const Color _lightBg = Color(0xFFF8F8F8);

  int _selectedPayment = 0; // 0 = Orange Money, 1 = Mobile Money, 2 = Card

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Récapitulatif', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: MockFirebase(),
        builder: (context, _) {
          final items = MockFirebase().cartItems;
          final subtotal = MockFirebase().cartSubtotal;
          final shipping = MockFirebase().cartShipping;
          final total = MockFirebase().cartTotal;
          final user = MockFirebase().currentUser;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('Votre panier est vide', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/discover'),
                    style: ElevatedButton.styleFrom(backgroundColor: _salmon, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Explorer les produits', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // ─── Adresse de livraison ───
                      _buildSectionTitle('Adresse de livraison'),
                      const SizedBox(height: 12),
                      _buildAddressCard(user),
                      const SizedBox(height: 24),
                      // ─── Articles ───
                      _buildSectionTitle('Mes articles (${items.length})'),
                      const SizedBox(height: 12),
                      ...items.map((item) => _buildOrderItem(item)),
                      const SizedBox(height: 24),
                      // ─── Moyen de paiement ───
                      _buildSectionTitle('Moyen de paiement'),
                      const SizedBox(height: 12),
                      _buildPaymentOptions(),
                      const SizedBox(height: 24),
                      // ─── Résumé ───
                      _buildSectionTitle('Résumé'),
                      const SizedBox(height: 12),
                      _buildSummaryCard(subtotal, shipping, total),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              _buildConfirmButton(context, total),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
  }

  Widget _buildAddressCard(Map<String, dynamic>? user) {
    final address = user?['address'] as Map<String, dynamic>? ?? {};
    final street = address['street'] ?? '123 Rue du Commerce';
    final city = address['city'] ?? 'Yaoundé';
    final country = address['country'] ?? 'Cameroun';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: _salmon.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.location_on_outlined, color: _salmon, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(street, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text('$city, $country', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/addresses'),
            child: const Text('Modifier', style: TextStyle(color: _salmon)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    final p = item['product'] as Map<String, dynamic>;
    final images = p['images'] as List? ?? [];
    final img = images.isNotEmpty ? images[0] : '';
    final qty = item['quantity'] ?? 1;
    final price = p['price'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(img, width: 65, height: 65, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 65, height: 65, color: Colors.grey[200])),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('Taille: ${item['size'] ?? '-'} · Qté: $qty', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Text('${(price * qty).toStringAsFixed(0)} XAF', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    final options = [
      {'icon': Icons.phone_android, 'name': 'Orange Money', 'color': Colors.orange},
      {'icon': Icons.phone_android, 'name': 'Mobile Money', 'color': Colors.yellow[800]},
      {'icon': Icons.credit_card, 'name': 'Carte Bancaire', 'color': Colors.blue},
    ];

    return Column(
      children: List.generate(options.length, (i) {
        final opt = options[i];
        final selected = _selectedPayment == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedPayment = i),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: selected ? _salmon.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? _salmon : Colors.grey[200]!, width: selected ? 2 : 1),
            ),
            child: Row(
              children: [
                Icon(opt['icon'] as IconData, color: opt['color'] as Color?, size: 24),
                const SizedBox(width: 14),
                Expanded(child: Text(opt['name'] as String, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal))),
                if (selected) const Icon(Icons.check_circle, color: _salmon, size: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard(double subtotal, double shipping, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          _buildPriceRow('Sous-total', '${subtotal.toStringAsFixed(0)} XAF'),
          const SizedBox(height: 10),
          _buildPriceRow('Livraison', '${shipping.toStringAsFixed(0)} XAF'),
          const Divider(height: 25),
          _buildPriceRow('TOTAL', '${total.toStringAsFixed(0)} XAF', bold: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: bold ? 16 : 14, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: bold ? 18 : 14, fontWeight: FontWeight.bold, color: bold ? _salmon : Colors.black)),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context, double total) {
    final paymentRoutes = ['/orange-money', '/mobile-money', '/card-payment'];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, paymentRoutes[_selectedPayment]),
          style: ElevatedButton.styleFrom(
            backgroundColor: _darkNavy,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                'Payer ${total.toStringAsFixed(0)} XAF',
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}