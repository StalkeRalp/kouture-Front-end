import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import '../vendor/vendor_profile_screen.dart';

class FavoritesTailorScreen extends StatelessWidget {
  final bool isTab;
  const FavoritesTailorScreen({super.key, this.isTab = false});

  static const String routeName = '/favorites-tailors';
  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _darkNavy = Color(0xFF0D0D26);

  @override
  Widget build(BuildContext context) {
    if (isTab) {
      return _buildBody(context);
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mes Couturiers Favoris', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        return FutureBuilder<List<dynamic>>(
          future: MockFirebase().getFavoriteVendors(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: _salmon));
            }

            final favoriteVendors = snapshot.data ?? [];

            if (favoriteVendors.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favoriteVendors.length,
              itemBuilder: (context, index) {
                final vendor = favoriteVendors[index];
                return _buildTailorCard(context, vendor);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text('Aucun couturier favori.', 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Text('Suivez vos couturiers préférés pour les retrouver ici !', 
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          if (!isTab) ...[
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkNavy,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('RETOUR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTailorCard(BuildContext context, Map<String, dynamic> vendor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(vendor['avatar'] ?? ''),
        ),
        title: Text(
          vendor['name'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${vendor['rating']}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.location_on, color: Colors.grey, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    vendor['location'] ?? '',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: _salmon),
          onPressed: () {
            MockFirebase().toggleFavorite(vendor['id'].toString());
          },
        ),
        onTap: () {
          Navigator.pushNamed(
            context, 
            VendorProfileScreen.routeName, 
            arguments: vendor['id']
          );
        },
      ),
    );
  }
}
