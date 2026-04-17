import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import '../../backend/translator.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  static const String routeName = '/notification-settings';

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  static const Color _salmon = Color(0xFFFF8C8C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(Translator.t('settings'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: MockFirebase(),
        builder: (context, _) {
          final user = MockFirebase().currentUser;
          final prefs = user?['preferences'] ?? {};

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            children: [
              _buildSectionTitle(Translator.t('general_notifications')),
              _buildSettingTile(
                title: Translator.t('push_notifications'),
                subtitle: Translator.t('push_notifications_desc'),
                value: prefs['push_notifications'] ?? true,
                onChanged: (val) => _updatePref('push_notifications', val),
              ),
              _buildSettingTile(
                title: Translator.t('vibrate'),
                subtitle: Translator.t('vibrate_desc'),
                value: prefs['vibrate'] ?? true,
                onChanged: (val) => _updatePref('vibrate', val),
              ),
              _buildSettingTile(
                title: Translator.t('sound'),
                subtitle: Translator.t('sound_desc'),
                value: prefs['sound'] ?? true,
                onChanged: (val) => _updatePref('sound', val),
              ),
              
              const SizedBox(height: 30),
              _buildSectionTitle(Translator.t('marketplace_updates')),
              _buildSettingTile(
                title: Translator.t('new_collections'),
                subtitle: Translator.t('new_collections_desc'),
                value: prefs['new_collections'] ?? true,
                onChanged: (val) => _updatePref('new_collections', val),
              ),
              _buildSettingTile(
                title: Translator.t('price_alerts'),
                subtitle: Translator.t('price_alerts_desc'),
                value: prefs['price_alerts'] ?? false,
                onChanged: (val) => _updatePref('price_alerts', val),
              ),
              _buildSettingTile(
                title: Translator.t('promotions'),
                subtitle: Translator.t('promotions_desc'),
                value: prefs['promotions'] ?? true,
                onChanged: (val) => _updatePref('promotions', val),
              ),

              const SizedBox(height: 30),
              _buildSectionTitle(Translator.t('order_activity')),
              _buildSettingTile(
                title: Translator.t('order_status'),
                subtitle: Translator.t('order_status_desc'),
                value: prefs['order_status_updates'] ?? true,
                onChanged: (val) => _updatePref('order_status_updates', val),
              ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    bool sent = await MockFirebase().sendTestNotification(
                      type: 'promo',
                      title: 'Test Promo!',
                      message: 'This is a simulation of a push notification.',
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(sent ? Translator.t('notification_sent') : Translator.t('notification_blocked')),
                          backgroundColor: sent ? Colors.green : Colors.orange,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: Text(Translator.t('simulate_push'), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _salmon,
                    side: const BorderSide(color: _salmon),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                Translator.t('verify_notifications'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          );
        },
      ),
    );
  }

  void _updatePref(String key, bool value) {
    final user = MockFirebase().currentUser;
    if (user == null) return;

    final prefs = Map<String, dynamic>.from(user['preferences'] ?? {});
    prefs[key] = value;

    MockFirebase().updateUser(user['id'], {'preferences': prefs});
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8C8C).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: _salmon,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey[200],
              trackOutlineColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }
}
