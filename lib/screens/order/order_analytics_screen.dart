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
        title: const Text('Statistiques & Historique',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: MockFirebase(),
        builder: (context, _) {
          final orders = MockFirebase().allOrders;
          if (orders.isEmpty) {
            return _buildEmptyState();
          }

          // Calculate summary stats
          final double totalSpent =
              orders.fold(0.0, (sum, o) => sum + (o['total'] ?? 0.0));
          final int totalItems = orders.fold(0, (sum, o) {
            final items = o['items'] as List? ?? [];
            return sum + items.fold(0, (s, i) => s + ((i['quantity'] ?? 1) as int));
          });

          // Get dynamic stats from backend
          final monthlyStats = MockFirebase().getOrdersStatsByMonth();
          final categoryStat = MockFirebase().getFavoriteCategoryStats();
          final paymentStat = MockFirebase().getMostUsedPaymentMethod();

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(orders.length, totalItems, totalSpent),
                const SizedBox(height: 30),
                const Text('Dépenses Récentes',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _darkNavy)),
                const SizedBox(height: 20),
                _buildDynamicChart(monthlyStats),
                const SizedBox(height: 30),
                const Text('Préférences de Commandes',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _darkNavy)),
                const SizedBox(height: 15),
                _buildDynamicPreferences(categoryStat, paymentStat),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 20),
          const Text(
            "Aucune donnée disponible",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _darkNavy),
          ),
          const SizedBox(height: 8),
          Text(
            "Vos statistiques apparaîtront ici\naprès vos premières commandes.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(int totalOrders, int totalItems, double totalSpent) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
              'Commandes', totalOrders.toString(), Icons.shopping_bag_outlined, _salmon),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
              'Dépensé (XAF)', '${totalSpent.toInt()}', Icons.wallet_outlined, _darkNavy),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration:
                BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 15),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          ),
          const SizedBox(height: 5),
          Text(title,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDynamicChart(Map<String, double> monthlyStats) {
    final maxSpent = monthlyStats.values.fold(1.0, (currMax, val) => val > currMax ? val : currMax);

    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: monthlyStats.entries.map((entry) {
          final barHeight = (entry.value / maxSpent) * 120 + 10; // min 10 height
          final isMax = entry.value == maxSpent && entry.value > 0;
          
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (entry.value > 0)
                  FittedBox(
                    child: Text(
                      '${(entry.value / 1000).toStringAsFixed(1)}k',
                      style: TextStyle(fontSize: 9, color: isMax ? _salmon : Colors.grey, fontWeight: isMax ? FontWeight.bold : FontWeight.normal),
                    ),
                  ),
                const SizedBox(height: 4),
                Container(
                  width: 28,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: isMax ? _salmon : _darkNavy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 10),
                Text(entry.key,
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: isMax ? FontWeight.bold : FontWeight.normal)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDynamicPreferences(Map<String, dynamic> catStat, Map<String, dynamic> payStat) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildPreferenceRow('Catégorie Favorite', catStat['name'], catStat['percent'], _salmon),
          const SizedBox(height: 20),
          _buildPreferenceRow('Mode de paiement', payStat['name'], payStat['percent'], _darkNavy),
          const SizedBox(height: 20),
          _buildPreferenceRow('Fidélité', 'Membre Gold', 100, const Color(0xFFEAB308)),
        ],
      ),
    );
  }

  Widget _buildPreferenceRow(
      String label, String value, int percent, Color color) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              Text(value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                    color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
              ),
              FractionallySizedBox(
                widthFactor: percent / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text('$percent%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
