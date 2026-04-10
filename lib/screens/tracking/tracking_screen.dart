import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  static const String routeName = '/tracking';
  static const Color _salmon = Color(0xFFFF8C8C);

  @override
  Widget build(BuildContext context) {
    final String? orderId = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Suivi du Colis', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: orderId == null
        ? const Center(child: Text('Erreur: Commande introuvable'))
        : FutureBuilder<Map<String, dynamic>?>(
            future: MockFirebase().getOrderById(orderId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: _salmon));
              }
              final order = snapshot.data;
              if (order == null) return const Center(child: Text('Commande non trouvée'));

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderHeader(order),
                    const SizedBox(height: 40),
                    const Text('Progressions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 30),
                    _buildTimeline(order['status']),
                  ],
                ),
              );
            },
          ),
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
                  const Text('Commande No.', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
              Expanded(child: Text(order['shippingAddress'], style: const TextStyle(fontSize: 14))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(String currentStatus) {
    final statuses = [
      {'label': 'Commande placée', 'desc': 'Votre commande a été reçue', 'icon': Icons.shopping_bag_outlined},
      {'label': 'Acceptée', 'desc': 'Le couturier a accepté votre commande', 'icon': Icons.check_circle_outline},
      {'label': 'En confection', 'desc': 'Votre tenue est en train d\'être cousue', 'icon': Icons.cut_outlined},
      {'label': 'Expédiée', 'desc': 'Le colis est en route vers vous', 'icon': Icons.local_shipping_outlined},
      {'label': 'Livrée', 'desc': 'Vous avez reçu votre colis', 'icon': Icons.home_outlined},
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
    switch (status) {
      case 'En attente': return 0;
      case 'Acceptée': return 1;
      case 'En confection': return 2;
      case 'Expédiée': return 3;
      case 'Livrée': return 4;
      default: return 0;
    }
  }
}
