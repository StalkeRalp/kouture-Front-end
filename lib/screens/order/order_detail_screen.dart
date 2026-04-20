import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import '../../backend/translator.dart';
import '../tracking/tracking_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:hugeicons/hugeicons.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  static const String routeName = '/order-detail';
  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _darkNavy = Color(0xFF0D0D26);

  @override
  Widget build(BuildContext context) {
    final String? orderId = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${Translator.t('order')} $orderId', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: Colors.black, size: 24.0),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (orderId != null)
            IconButton(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedDownload01, color: Colors.black, size: 24.0),
              onPressed: () async {
                final order = await MockFirebase().getOrderById(orderId);
                if (order != null && context.mounted) {
                  await _generateAndDownloadPdf(context, order);
                }
              },
            ),
          IconButton(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedHelpCircle, color: Colors.black, size: 24.0),
            onPressed: () {},
          ),
        ],
      ),
          body: AnimatedBuilder(
            animation: MockFirebase(),
            builder: (context, _) {
              return orderId == null 
                ? Center(child: Text(Translator.t('error_order_not_found')))
                : FutureBuilder<Map<String, dynamic>?>(
                    future: MockFirebase().getOrderById(orderId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: _salmon));
                      }
                      final order = snapshot.data;
                      if (order == null) {
                        return Center(child: Text(Translator.t('error_order_not_found')));
                      }

                      return Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildStatusCard(order),
                                  const SizedBox(height: 30),
                                  _buildSectionTitle(Translator.t('articles')),
                                  const SizedBox(height: 15),
                                  ... (order['items'] as List).map((item) => _buildProductItem(item)),
                                  const SizedBox(height: 30),
                                  _buildSectionTitle(Translator.t('shipping')),
                                  const SizedBox(height: 15),
                                  _buildInfoTile(HugeIcons.strokeRoundedLocation01, Translator.t('my_addresses'), order['shippingAddress']),
                                  const SizedBox(height: 15),
                                  _buildInfoTile(HugeIcons.strokeRoundedCreditCard, Translator.t('payment_method'), order['paymentMethod']),
                                  const SizedBox(height: 30),
                                  _buildSectionTitle(Translator.t('summary')),
                                  const SizedBox(height: 15),
                                  _buildPriceSummary(order),
                                ],
                              ),
                            ),
                          ),
                          _buildBottomActions(context, orderId),
                        ],
                      );
                    },
                  );
            },
          ),
    );
  }

  Widget _buildStatusCard(Map<String, dynamic> order) {
    String translationKey;
    switch (order['status']) {
      case 'En attente': translationKey = 'status_pending'; break;
      case 'Acceptée': translationKey = 'status_accepted'; break;
      case 'En confection': translationKey = 'status_confection'; break;
      case 'Expédiée': translationKey = 'status_shipped'; break;
      case 'Livrée': translationKey = 'status_delivered'; break;
      default: translationKey = order['status'];
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _salmon.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _salmon.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          HugeIcon(icon: HugeIcons.strokeRoundedTruck, color: _salmon, size: 40),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${Translator.t('status')} : ${Translator.t(translationKey)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _salmon)),
                const SizedBox(height: 4),
                Text('${Translator.t('updated_on')} ${_formatDate(order['date'])}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18));
  }

  Widget _buildProductItem(Map<String, dynamic> item) {
    final p = item['product'];
    final images = p['images'] as List;
    final img = images.isNotEmpty ? images[0] : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(img, width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 70, height: 70, color: Colors.grey[200])),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text('${Translator.t('quantity')}: ${item['quantity']} • ${Translator.t('size')}: ${item['size']}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Text('${p['price'] * item['quantity']} XAF', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInfoTile(dynamic icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
          child: HugeIcon(icon: icon, size: 20, color: Colors.grey[700]),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSummary(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _buildPriceRow(Translator.t('total_items'), '${order['total'] - 2000} XAF'),
          const SizedBox(height: 10),
          _buildPriceRow(Translator.t('delivery_fees'), '2000 XAF'),
          const Divider(height: 30),
          _buildPriceRow(Translator.t('total'), '${order['total']} XAF', isBold: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: isBold ? 18 : 14, fontWeight: FontWeight.bold, color: isBold ? _salmon : Colors.black)),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context, String orderId) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))]),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _darkNavy),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: Text(Translator.t('cancel'), style: const TextStyle(color: _darkNavy, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, TrackingScreen.routeName, arguments: orderId),
              style: ElevatedButton.styleFrom(
                backgroundColor: _salmon,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
              ),
              child: Text(Translator.t('track_order'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final date = DateTime.parse(iso);
      final monthKeys = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
      final month = Translator.t(monthKeys[date.month - 1]);
      final at = (Translator.currentLanguage == 'Français') ? 'à' : ((Translator.currentLanguage == 'English') ? 'at' : 'a');
      
      return '${date.day} $month ${date.year} $at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  Future<void> _generateAndDownloadPdf(BuildContext context, Map<String, dynamic> order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('KOUTURE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
              pw.SizedBox(height: 10),
              pw.Text('${Translator.t('invoice_title')}: ${order['id']}'),
              pw.Text('${Translator.t('status')} : ${Translator.t(order['status'] == 'En attente' ? 'status_pending' : (order['status'] == 'Acceptée' ? 'status_accepted' : (order['status'] == 'En confection' ? 'status_confection' : (order['status'] == 'Expédiée' ? 'status_shipped' : (order['status'] == 'Livrée' ? 'status_delivered' : order['status'])))))}'),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text('${Translator.t('articles')}:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              ... (order['items'] as List).map((item) {
                final product = item['product'];
                final qty = item['quantity'];
                final price = product['price'];
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('- ${product['name']} (x$qty)'),
                    pw.Text('${qty * price} XAF'),
                  ],
                );
              }).toList(),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(Translator.t('subtotal')),
                  pw.Text('${order['total'] - 2000} XAF'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(Translator.t('delivery_fees')),
                  pw.Text('2000 XAF'),
                ],
              ),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(Translator.t('total').toUpperCase(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('${order['total']} XAF', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Call Printing.sharePdf which will open a save/print dialog 
    await Printing.sharePdf(bytes: await pdf.save(), filename: '${order['id']}.pdf');
  }
}
