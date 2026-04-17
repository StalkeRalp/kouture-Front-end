import 'package:flutter/material.dart';
import '../../backend/translator.dart';
import '../../backend/mock_firebase.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  static const String routeName = '/tracking';
  static const Color _salmon = Color(0xFFFF8C8C);

  @override
  Widget build(BuildContext context) {
    final String? orderId = ModalRoute.of(context)?.settings.arguments as String?;

    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(Translator.t('track_order'), style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: orderId == null
            ? Center(child: Text(Translator.t('error_order_not_found')))
            : FutureBuilder<Map<String, dynamic>?>(
                future: MockFirebase().getOrderById(orderId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: _salmon));
                  }
                  final order = snapshot.data;
                  if (order == null) return Center(child: Text(Translator.t('error_order_not_found')));

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderHeader(order),
                        const SizedBox(height: 40),
                        Text(Translator.t('progressions'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 30),
                        _buildTimeline(order['status']),
                      ],
                    ),
                  );
                },
              ),
        );
      },
    );
  }

  Widget _buildOrderHeader(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Translator.t('order_no'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  Text(order['id'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const Icon(Icons.qr_code, size: 40, color: Colors.black87),
            ],
          ),
          const Divider(height: 40),
          Row(
            children: [
              const Icon(Icons.location_on, color: _salmon, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(order['shippingAddress'] ?? '', style: const TextStyle(fontSize: 14))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(String currentStatus) {
    final statuses = [
      {'label': Translator.t('status_placed'), 'desc': Translator.t('status_placed_desc'), 'icon': Icons.shopping_bag_outlined},
      {'label': Translator.t('status_accepted'), 'desc': Translator.t('status_accepted_desc'), 'icon': Icons.check_circle_outline},
      {'label': Translator.t('status_confection'), 'desc': Translator.t('status_confection_desc'), 'icon': Icons.cut_outlined},
      {'label': Translator.t('status_shipped'), 'desc': Translator.t('status_shipped_desc'), 'icon': Icons.local_shipping_outlined},
      {'label': Translator.t('status_delivered'), 'desc': Translator.t('status_delivered_desc'), 'icon': Icons.home_outlined},
    ];

    int currentIndex = _getStatusIndex(currentStatus);

    return Column(
      children: List.generate(statuses.length, (index) {
        final isCompleted = index <= currentIndex;
        final isLast = index == statuses.length - 1;
        final s = statuses[index];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted ? _salmon : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(s['icon'] as IconData, size: 20, color: isCompleted ? Colors.white : Colors.grey),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 50,
                    color: isCompleted ? _salmon : Colors.grey[200],
                  ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s['label'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isCompleted ? Colors.black : Colors.grey)),
                  const SizedBox(height: 4),
                  Text(s['desc'] as String, style: TextStyle(color: isCompleted ? Colors.grey[600] : Colors.grey[400], fontSize: 13)),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  int _getStatusIndex(String status) {
    if (status == 'En attente') return 0;
    if (status == 'Acceptée') return 1;
    if (status == 'En confection') return 2;
    if (status == 'Expédiée') return 3;
    if (status == 'Livrée') return 4;
    return 0;
  }
}
