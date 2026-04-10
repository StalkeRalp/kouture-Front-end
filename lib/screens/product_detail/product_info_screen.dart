import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';

class ProductInfoScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductInfoScreen({super.key, required this.product});

  static const String routeName = '/product-info';
  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _darkNavy = Color(0xFF0D0D26);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Informations Détaillées', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Description Complète'),
            const SizedBox(height: 10),
            Text(
              product['description'] ?? 'Aucune description disponible.',
              style: TextStyle(color: Colors.grey[700], fontSize: 15, height: 1.5),
            ),
            
            const SizedBox(height: 30),
            _buildSectionTitle('Spécifications Techniques'),
            const SizedBox(height: 15),
            _buildInfoRow('Catégorie', product['category'] ?? '-'),
            _buildInfoRow('Matière', product['material'] ?? 'Non spécifiée'),
            _buildInfoRow('Entretien', product['care'] ?? 'Lavage standard'),
            _buildInfoRow('Origine', product['origin'] ?? 'Inconnue'),
            _buildInfoRow('Stock restant', '${product['stock'] ?? 0} unités'),
            _buildInfoRow('SKU', 'KT-${product['id']?.toString().toUpperCase()}'),
            _buildInfoRow('Livraison', product['shippingInfo'] ?? '3-5 jours'),
            
            const SizedBox(height: 30),
            _buildSectionTitle('Vendeur'),
            const SizedBox(height: 15),
            FutureBuilder<Map<String, dynamic>?>(
              future: MockFirebase().getVendorById(product['vendorId']?.toString() ?? ''),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final v = snapshot.data!;
                return Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(v['avatar'] ?? ''),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 2),
                            Text(v['location'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          ],
                        ),
                      ),
                      const Icon(Icons.verified, color: Colors.blue, size: 20),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 30),
            _buildSectionTitle('Tags & Mots-clés'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (product['tags'] as List? ?? []).map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _salmon.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _salmon.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '#$tag',
                    style: const TextStyle(color: _salmon, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 40),
            Center(
              child: Text(
                'Kouture Premium Standards',
                style: TextStyle(color: Colors.grey[400], fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _darkNavy),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }
}
