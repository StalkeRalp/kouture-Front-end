import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import 'dart:math' as math;

class OrderAnalyticsScreen extends StatefulWidget {
  const OrderAnalyticsScreen({super.key});

  static const String routeName = '/order-analytics';

  @override
  State<OrderAnalyticsScreen> createState() => _OrderAnalyticsScreenState();
}

class _OrderAnalyticsScreenState extends State<OrderAnalyticsScreen> {
  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _darkNavy = Color(0xFF0D0D26);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Statistiques & Historique', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: Future.value(MockFirebase().allOrders),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _salmon));
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text("Aucune donnée disponible pour l'instant."));
          }

          // Calculate some stats
          final double totalSpent = orders.fold(0.0, (sum, o) => sum + (o['total'] ?? 0.0));
          final int totalItems = orders.fold(0, (sum, o) {
            final items = o['items'] as List? ?? [];
            return sum + items.fold(0, (s, i) => s + ((i['quantity'] ?? 1) as int));
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(orders.length, totalItems, totalSpent),
                const SizedBox(height: 30),
                const Text('Dépenses Récentes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _darkNavy)),
                const SizedBox(height: 20),
                _buildChart(),
                const SizedBox(height: 30),
                const Text('Préférences de Commandes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _darkNavy)),
                const SizedBox(height: 15),
                _buildPreferences(orders),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(int totalOrders, int totalItems, double totalSpent) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Commandes', totalOrders.toString(), Icons.shopping_bag_outlined, _salmon),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard('Dépensé (XAF)', '${totalSpent.toInt()}', Icons.wallet_outlined, _darkNavy),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 15),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 5),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildChart() {
    // Simple bar chart layout
    final data = [40, 80, 50, 100, 70, 90, 60]; // Mock monthly data heights
    final labels = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil'];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(data.length, (index) {
          final isMax = data[index] == 100;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 30,
                height: data[index].toDouble(),
                decoration: BoxDecoration(
                  color: isMax ? _salmon : _darkNavy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 10),
              Text(labels[index], style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: isMax ? FontWeight.bold : FontWeight.normal)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPreferences(List<dynamic> orders) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildPreferenceRow('Catégorie Favorite', 'Prêt-à-porter', 75, _salmon),
          const SizedBox(height: 20),
          _buildPreferenceRow('Mode de paiement', 'Mobile Money', 60, _darkNavy),
          const SizedBox(height: 20),
          _buildPreferenceRow('Fidélité', 'Gold', 90, const Color(0xFFEAB308)),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow(String label, String value, int percent, Color color) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            height: 8,
            decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
            child: Row(
              children: [
                Expanded(
                  flex: percent,
                  child: Container(
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                Expanded(
                  flex: 100 - percent,
                  child: const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
