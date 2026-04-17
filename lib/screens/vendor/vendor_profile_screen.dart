import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import '../../backend/translator.dart';
import '../chat/chat_detail_screen.dart';
import './vendor_products_screen.dart';

class VendorProfileScreen extends StatelessWidget {
  const VendorProfileScreen({super.key});

  static const String routeName = '/vendor-profile';
  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _darkNavy = Color(0xFF0D0D26);

  @override
  Widget build(BuildContext context) {
    final String vendorId = ModalRoute.of(context)?.settings.arguments as String? ?? 'v1';

    return FutureBuilder<Map<String, dynamic>?>(
      future: MockFirebase().getVendorById(vendorId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final vendor = snapshot.data!;

        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, vendor),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(vendor['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(vendor['location'] ?? '', style: TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                            ],
                          ),
                          if (vendor['isVerified'] == true)
                            const Icon(Icons.verified, color: Colors.blue, size: 30),
                        ],
                      ),
                      const SizedBox(height: 25),
                      _buildStats(vendor),
                      const SizedBox(height: 30),
                      Text(Translator.t('about'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      Text(
                        vendor['description'] ?? '',
                        style: TextStyle(color: Colors.grey[700], height: 1.6, fontSize: 15),
                      ),
                      const SizedBox(height: 40),
                      _buildActions(context, vendor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> vendor) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Image.network(
          vendor['coverImage'] ?? '',
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 50,
          left: 10,
          child: IconButton(
            icon: const ContainerCircle(child: Icon(Icons.chevron_left, color: Colors.black)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          top: 50,
          right: 10,
          child: AnimatedBuilder(
            animation: MockFirebase(),
            builder: (context, _) {
              final isFav = MockFirebase().isFavorite(vendor['id'].toString());
              return IconButton(
                icon: ContainerCircle(
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? _salmon : Colors.black,
                  ),
                ),
                onPressed: () => MockFirebase().toggleFavorite(vendor['id'].toString()),
              );
            },
          ),
        ),
        Positioned(
          bottom: -40,
          left: 24,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 45,
              backgroundImage: NetworkImage(vendor['avatar'] ?? ''),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(Map<String, dynamic> vendor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(vendor['rating'].toString(), Translator.t('rating_label'), Icons.star),
          _buildStatItem(vendor['totalReviews'].toString(), Translator.t('reviews'), Icons.comment),
          _buildStatItem(vendor['totalSales'].toString(), Translator.t('sales'), Icons.shopping_bag),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: _salmon),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }

  Widget _buildActions(BuildContext context, Map<String, dynamic> vendor) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, VendorProductsScreen.routeName, arguments: vendor['id']),
            style: ElevatedButton.styleFrom(
              backgroundColor: _darkNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text(Translator.t('view_products'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 15),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, ChatDetailScreen.routeName, arguments: {
            'chatId': 'chat1',
            'vendorName': vendor['name'],
            'vendorAvatar': vendor['avatar'],
          }),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: _salmon, borderRadius: BorderRadius.circular(15)),
            child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class ContainerCircle extends StatelessWidget {
  final Widget child;
  const ContainerCircle({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: child,
    );
  }
}
