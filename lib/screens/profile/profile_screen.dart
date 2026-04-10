import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profile';
  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _darkNavy = Color(0xFF0D0D26);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        final user = MockFirebase().currentUser;
        if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: _salmon)));

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.black),
                onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: _salmon.withOpacity(0.1),
                            backgroundImage: NetworkImage(user['avatar'] ?? 'https://i.pravatar.cc/300'),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: _darkNavy, shape: BoxShape.circle),
                                child: const Icon(Icons.edit, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            const SizedBox(height: 4),
                            Text(user['email'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                            const SizedBox(height: 4),
                            Text(user['phone'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Quick Links Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _buildQuickLink(context, Icons.inventory_2_outlined, 'Mes Commandes', '/orders'),
                      const SizedBox(width: 12),
                      _buildQuickLink(context, Icons.favorite_outline, 'Mes Favoris', '/favorites'),
                      const SizedBox(width: 12),
                      _buildQuickLink(context, Icons.settings_outlined, 'Paramètres', '/settings'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Info Section
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Informations personnelles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 15),
                      _buildInfoRow(Icons.person_outline, 'Nom', user['name']),
                      _buildInfoRow(Icons.email_outlined, 'Email', user['email']),
                      _buildInfoRow(Icons.phone_outlined, 'Téléphone', user['phone']),
                      _buildInfoRow(Icons.location_on_outlined, 'Ville', user['address']?['city'] ?? 'Yaoundé'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Menu Links
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _buildMenuTile(context, Icons.analytics_outlined, 'Statistiques', '/order-analytics'),
                      _buildMenuTile(context, Icons.chat_bubble_outline, 'Messages', '/chat-list'),
                      _buildMenuTile(context, Icons.notifications_outlined, 'Notifications', '/notifications'),
                      _buildMenuTile(context, Icons.payment_outlined, 'Méthodes de paiement', '/payment-methods'),
                      _buildMenuTile(context, Icons.help_outline, 'Aide & Support', '/help'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Logout
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('SE DÉCONNECTER', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickLink(BuildContext context, IconData icon, String label, String route) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: Column(
            children: [
              Icon(icon, color: _salmon, size: 26),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: _salmon, size: 20),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              Text(value ?? '-', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}
