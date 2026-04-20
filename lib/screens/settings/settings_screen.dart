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
import 'package:kouture/screens/address/address_list_screen.dart';
import 'package:kouture/screens/settings/help_screen.dart';
import '../../backend/mock_firebase.dart';
import '../../backend/translator.dart';
import 'package:hugeicons/hugeicons.dart';

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
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          Translator.t('settings'),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.1,
          ),
        ),
        actions: [
          IconButton(
            icon: HugeIcon(icon: HugeIcons.strokeRoundedNotification01, color: Colors.black, size: 24.0),
            onPressed: () => Navigator.pushNamed(context, NotificationSettingsScreen.routeName),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      body: AnimatedBuilder(
        animation: MockFirebase(),
        builder: (context, _) {
          final user = MockFirebase().currentUser;
          final country = user?['preferences']?['country'] ?? 'Cameroun';
          final language = user?['preferences']?['language'] ?? 'English';
          final currency = user?['preferences']?['currency'] ?? 'XAF 🇨🇲';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(Translator.t('personal')),
                _buildListItem(
                  Translator.t('my_profile'),
                  onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName),
                ),
                _buildDivider(),
                _buildListItem(
                  Translator.t('my_measurements'),
                  onTap: () => Navigator.pushNamed(context, MeasurementsScreen.routeName),
                ),
                _buildDivider(),
                _buildListItem(
                  Translator.t('shipping_addresses'),
                  onTap: () => Navigator.pushNamed(context, AddressListScreen.routeName),
                ),
                _buildDivider(),
                _buildListItem(
                  Translator.t('favorites'),
                  onTap: () => Navigator.pushNamed(context, FavoritesScreen.routeName),
                ),
                _buildDivider(),
                _buildListItem(
                  Translator.t('notification_settings'),
                  onTap: () => Navigator.pushNamed(context, NotificationSettingsScreen.routeName),
                ),
                
                _buildSectionHeader(Translator.t('shop')),
                _buildListItem(Translator.t('country'), value: country, onTap: () => Navigator.pushNamed(context, CountryScreen.routeName)),
                _buildDivider(),
                _buildListItem(Translator.t('currency'), value: currency, onTap: () => Navigator.pushNamed(context, CurrencyScreen.routeName)),
                _buildDivider(),
                _buildListItem(
                  Translator.t('terms_conditions'),
                  onTap: () => Navigator.pushNamed(context, PrivacyScreen.routeName),
                ),
                
                 _buildSectionHeader(Translator.t('account')),
                _buildListItem(
                  Translator.t('language'),
                  value: language,
                  onTap: () => Navigator.pushNamed(context, LanguageScreen.routeName),
                ),
                _buildDivider(),
                _buildListItem(
                  Translator.t('help_support'),
                  onTap: () => Navigator.pushNamed(context, HelpScreen.routeName),
                ),
                _buildDivider(),
                _buildListItem(
                  Translator.t('about_kouture'),
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
                        '${Translator.t('version')} 1.0 Avril, 2026',
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
          );
        },
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
                HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 14,
                  color: Colors.black87,),
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
