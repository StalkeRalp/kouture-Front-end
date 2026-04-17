import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import '../../backend/translator.dart';
import 'edit_profile_screen.dart';
import '../auth/login_screen.dart';
import '../activities/activities_screen.dart';
import '../favorites/favorites_screen.dart';
import '../settings/settings_screen.dart';
import '../order/order_analytics_screen.dart';
import '../address/address_list_screen.dart';
import '../settings/help_screen.dart';

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
            automaticallyImplyLeading: false,
            title: Text(Translator.t('profile'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.black),
                onPressed: () => Navigator.pushNamed(context, EditProfileScreen.routeName),
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
                            backgroundColor: _salmon.withValues(alpha: 0.1),
                            backgroundImage: NetworkImage(user['avatar'] ?? 'https://i.pravatar.cc/300'),
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, EditProfileScreen.routeName),
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
                      _buildQuickLink(context, Icons.inventory_2_outlined, Translator.t('orders'), ActivitiesScreen.routeName, arguments: 1),
                      const SizedBox(width: 12),
                      _buildQuickLink(context, Icons.favorite_outline, Translator.t('favorites'), FavoritesScreen.routeName),
                      const SizedBox(width: 12),
                      _buildQuickLink(context, Icons.settings_outlined, Translator.t('settings'), SettingsScreen.routeName),
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
                      Text(Translator.t('personal_info'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 15),
                      _buildInfoRow(Icons.person_outline, Translator.t('full_name'), user['name']),
                      _buildInfoRow(Icons.email_outlined, Translator.t('email'), user['email']),
                      _buildInfoRow(Icons.phone_outlined, Translator.t('help_support'), user['phone']), // Use phone if specific key missing
                      _buildInfoRow(Icons.location_on_outlined, Translator.t('city'), user['address']?['city'] ?? 'Yaoundé'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Menu Links
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _buildMenuTile(context, Icons.analytics_outlined, Translator.t('statistics'), OrderAnalyticsScreen.routeName),
                      _buildMenuTile(context, Icons.chat_bubble_outline, Translator.t('messages'), ActivitiesScreen.routeName, arguments: 0),
                      _buildMenuTile(context, Icons.location_on_outlined, Translator.t('my_addresses'), AddressListScreen.routeName),
                      _buildMenuTile(context, Icons.help_outline, Translator.t('help_support'), HelpScreen.routeName),
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
                      onPressed: () => _showLogoutDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[50],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text(Translator.t('logout').toUpperCase(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 1)),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout_rounded, color: Colors.red, size: 32),
                ),
                const SizedBox(height: 24),
                Text(
                  Translator.t('logout'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  Translator.t('logout_confirm'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        child: Text(
                          Translator.t('no'),
                          style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          MockFirebase().logout();
                          Navigator.pop(context); // Close dialog
                          Navigator.pushReplacementNamed(context, LoginScreen.routeName);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _salmon,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          Translator.t('yes'),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickLink(BuildContext context, IconData icon, String label, String route, {Object? arguments}) {
    return Expanded(
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, route, arguments: arguments),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
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

  Widget _buildMenuTile(BuildContext context, IconData icon, String label, String route, {Object? arguments}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () => Navigator.pushNamed(context, route, arguments: arguments),
    );
  }
}
