import 'package:flutter/material.dart';
import 'package:kouture/screens/profile/profile_screen.dart';
import 'package:kouture/screens/favorites/favorites_screen.dart';
import 'package:kouture/screens/payment/payment_method_screen.dart';
import 'package:kouture/screens/notifications/notification_settings_screen.dart';
import 'package:kouture/screens/settings/language_screen.dart';
import 'package:kouture/screens/settings/about_screen.dart';
import 'package:kouture/screens/settings/privacy_screen.dart';
import 'package:kouture/screens/settings/country_screen.dart';
import 'package:kouture/screens/settings/currency_screen.dart';
import 'package:kouture/screens/settings/measurements_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String routeName = '/settings';

  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _secondaryPink = Color(0xFFFDECEC); 
  static const Color _sectionBg = Color(0xFFFDECEC); 
  static const Color _sectionText = Color(0xFF0D0D26); 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Paramètres',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, '/notification-settings'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Personal'),
            _buildListItem(
              'My Profile',
              onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName),
            ),
            _buildDivider(),
            _buildListItem(
              'My Measurements',
              onTap: () => Navigator.pushNamed(context, MeasurementsScreen.routeName),
            ),
            _buildDivider(),
            _buildListItem(
              'Shipping Addresses',
              onTap: () => Navigator.pushNamed(context, '/addresses'),
            ),
            _buildDivider(),
            _buildListItem(
              'Favoris',
              onTap: () => Navigator.pushNamed(context, FavoritesScreen.routeName),
            ),
            _buildDivider(),
            _buildListItem(
              'Notification Settings',
              onTap: () => Navigator.pushNamed(context, NotificationSettingsScreen.routeName),
            ),
            
            _buildSectionHeader('Shop'),
            _buildListItem('Country', value: 'Cameroun', onTap: () => Navigator.pushNamed(context, CountryScreen.routeName)),
            _buildDivider(),
            _buildListItem('Currency', value: 'XAF 🇨🇲', onTap: () => Navigator.pushNamed(context, CurrencyScreen.routeName)),
            _buildDivider(),
            _buildListItem(
              'Terms and Conditions',
              onTap: () => Navigator.pushNamed(context, PrivacyScreen.routeName),
            ),
            
             _buildSectionHeader('Account'),
            _buildListItem(
              'Language',
              value: 'English',
              onTap: () => Navigator.pushNamed(context, LanguageScreen.routeName),
            ),
            _buildDivider(),
            _buildListItem(
              'Aide & Support',
              onTap: () => Navigator.pushNamed(context, '/help'),
            ),
            _buildDivider(),
            _buildListItem(
              'About Kouture',
              onTap: () => Navigator.pushNamed(context, AboutScreen.routeName),
            ),
            _buildDivider(),
            
            const SizedBox(height: 30),
            
            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kouture',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0 Avril, 2026',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      color: _sectionBg,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: _sectionText,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildListItem(String title, {String? value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                if (value != null) ...[
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.black87,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
    );
  }
}
