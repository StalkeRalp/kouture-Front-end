import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import '../../backend/translator.dart';
import '../main_navigation_screen.dart';

class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

  static const String routeName = '/order-confirmation';

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  static const Color _navy = Color(0xFF0D0D26);
  static const Color _rose = Color(0xFFFF8C8C);
  
  Map<String, dynamic>? _lastOrder;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLastOrder();
  }

  Future<void> _fetchLastOrder() async {
    // Just fetch the most recently placed order for the receipt.
    // Realistically, orderId would be passed as an argument.
    final orders = MockFirebase().allOrders;
    if (orders.isNotEmpty) {
      _lastOrder = orders.first;
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: Text(
              Translator.t('order_receipt'),
              style: const TextStyle(
                color: _navy,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: const IconThemeData(color: _navy),
            automaticallyImplyLeading: false, // Prevent going back to success screen
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  MainNavigationScreen.routeName,
                  (route) => false,
                ),
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator(color: _rose))
              : _lastOrder == null
                  ? const Center(child: Text('No order data found.'))
                  : _buildReceipt(_lastOrder!),
        );
      },
    );
  }

  Widget _buildReceipt(Map<String, dynamic> order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
      child: Column(
        children: [
          // Success Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _rose.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline, color: _rose, size: 60),
          ),
          const SizedBox(height: 16),
          Text(
            Translator.t('order_confirmed'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _navy),
          ),
          const SizedBox(height: 8),
          Text(
            'Order #${order['id']}',
            style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),

          // Receipt Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined, color: _navy),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Translator.t('delivery_estimate'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              '${order['shippingAddress'] ?? 'Standard Delivery'}',
                              style: const TextStyle(color: _navy, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: (order['items'] as List).length,
                  itemBuilder: (context, index) {
                    final item = order['items'][index];
                    final product = item['product'] ?? item;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[100],
                              image: product['image'] != null || (product['images'] != null && (product['images'] as List).isNotEmpty)
                                  ? DecorationImage(
                                      image: NetworkImage(product['image'] ?? product['images'][0]),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: (product['image'] == null && (product['images'] == null || (product['images'] as List).isEmpty))
                                ? const Icon(Icons.image, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['name'] ?? product['productName'] ?? 'Product',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _navy),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Qty: ${item['quantity'] ?? item['qty'] ?? 1}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${product['price']} XAF',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          )
                        ],
                      ),
                    );
                  },
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Translator.t('total_paid'),
                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        '${order['total']} XAF',
                        style: const TextStyle(color: _rose, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                MainNavigationScreen.routeName,
                (route) => false,
                arguments: 1, // Go to activities/orders
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              Translator.t('order_details'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}
