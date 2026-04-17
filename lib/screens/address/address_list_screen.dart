import 'package:flutter/material.dart';
import '../../backend/translator.dart';
import '../../backend/mock_firebase.dart';
import 'add_address_screen.dart';

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key});

  static const String routeName = '/addresses';
  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _darkNavy = Color(0xFF0D0D26);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(Translator.t('my_addresses'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: MockFirebase(),
        builder: (context, _) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: MockFirebase().getAddresses(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: _salmon));
              }

              final addresses = snapshot.data ?? [];

              if (addresses.isEmpty) {
                return _buildEmptyState(context);
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        return _buildAddressCard(context, address);
                      },
                    ),
                  ),
                  _buildAddButton(context),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            Translator.t('no_addresses'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              Translator.t('add_address_desc'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 40),
          _buildAddButton(context),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, Map<String, dynamic> address) {
    final bool isDefault = address['isDefault'] ?? false;
    final String label = address['label'] ?? '';
    final String translatedLabel = label == 'Maison' ? Translator.t('home') : (label == 'Bureau' ? Translator.t('work') : label);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDefault ? _salmon : Colors.grey.shade200,
          width: isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      label == 'Maison' ? Icons.home_filled : Icons.work,
                      color: isDefault ? _salmon : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      translatedLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                if (isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _salmon.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      Translator.t('default'),
                      style: const TextStyle(color: _salmon, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              address['fullName'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '${address['street']}, ${address['city']}, ${address['region']}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              address['phone'] ?? '',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isDefault)
                  TextButton(
                    onPressed: () => MockFirebase().setDefaultAddress(address['id']),
                    child: Text(Translator.t('set_as_default'), style: const TextStyle(color: _salmon, fontSize: 13)),
                  ),
                if (!isDefault) const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => _showDeleteConfirmation(context, address['id']),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: () => Navigator.pushNamed(context, AddAddressScreen.routeName),
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkNavy,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text(
          Translator.t('add_new_address'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translator.t('delete_address_title')),
        content: Text(Translator.t('delete_address_desc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Translator.t('cancel'), style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              MockFirebase().deleteAddress(id);
              Navigator.pop(context);
            },
            child: Text(Translator.t('delete'), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
