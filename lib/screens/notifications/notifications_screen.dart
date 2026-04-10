import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const String routeName = '/notifications';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () => MockFirebase().markAllAsRead(),
            child: const Text('Mark all read', style: TextStyle(color: Color(0xFFFF8C8C), fontSize: 13)),
          ),
          TextButton(
            onPressed: () => MockFirebase().clearAllNotifications(),
            child: const Text('Clear All', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: MockFirebase(),
        builder: (context, _) {
          return FutureBuilder<List<dynamic>>(
            future: MockFirebase().getNotifications(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C8C)));
              }

              final notifications = snapshot.data ?? [];

              if (notifications.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey.withOpacity(0.05), height: 1),
                itemBuilder: (context, index) {
                  return _buildNotificationItem(context, notifications[index]);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, Map<String, dynamic> notification) {
    final bool isRead = notification['isRead'] ?? false;
    final String type = notification['type'] ?? 'order';
    
    // Choose icon based on type
    IconData icon;
    Color iconColor;
    switch (type) {
      case 'order':
        icon = Icons.local_shipping_outlined;
        iconColor = Colors.blue;
        break;
      case 'promo':
        icon = Icons.sell_outlined;
        iconColor = Colors.orange;
        break;
      case 'chat':
        icon = Icons.chat_bubble_outline;
        iconColor = Colors.green;
        break;
      default:
        icon = Icons.notifications_none;
        iconColor = const Color(0xFFFF8C8C);
    }

    return InkWell(
      onTap: () {
        MockFirebase().markNotificationAsRead(notification['id']);
        // Add navigation logic if needed
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: isRead ? Colors.transparent : const Color(0xFFFF8C8C).withOpacity(0.03),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification['title'] ?? 'Notification',
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                          fontSize: 15,
                          color: isRead ? Colors.black54 : Colors.black87,
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF8C8C),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['message'] ?? '',
                    style: TextStyle(
                      color: isRead ? Colors.grey[500] : Colors.black54,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(notification['createdAt']),
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? dateTimeStr) {
    if (dateTimeStr == null) return '';
    try {
      final dt = DateTime.parse(dateTimeStr);
      return DateFormat('dd MMM, hh:mm a').format(dt);
    } catch (e) {
      return dateTimeStr;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8C8C).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_off_outlined, size: 64, color: const Color(0xFFFF8C8C).withOpacity(0.3)),
          ),
          const SizedBox(height: 24),
          const Text(
            'No notifications yet',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            'We will notify you when something important arrives.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
