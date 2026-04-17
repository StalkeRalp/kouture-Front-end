import 'package:flutter/material.dart';
import '../../backend/translator.dart';
import '../../backend/mock_firebase.dart';
import '../chat/chat_detail_screen.dart';
import '../order/order_detail_screen.dart';

class ActivitiesScreen extends StatefulWidget {
  final int initialTabIndex; // 0 for Messages, 1 for Orders
  const ActivitiesScreen({super.key, this.initialTabIndex = 0});

  static const String routeName = '/activities';

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  late int _containerIndex;

  @override
  void initState() {
    super.initState();
    _containerIndex = widget.initialTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              _containerIndex == 0 ? Translator.t('messages').toUpperCase() : Translator.t('orders').toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF0D0D26), 
                fontWeight: FontWeight.bold, 
                fontSize: 16, 
                letterSpacing: 1.5
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Unified Switch Bar
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildTab(0, Translator.t('messages'))),
                    Expanded(child: _buildTab(1, Translator.t('orders'))),
                  ],
                ),
              ),
              
              Expanded(
                child: _containerIndex == 0 ? _buildChatList() : _buildOrdersList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(int index, String label) {
    final bool active = _containerIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _containerIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: active 
            ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)] 
            : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: active ? _navy : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // --- CHAT LOGIC ---

  Widget _buildChatList() {
    return FutureBuilder<List<dynamic>>(
      future: MockFirebase().getChatList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _salmon));
        }
        final chats = snapshot.data ?? [];
        if (chats.isEmpty) {
          return _buildChatEmptyState();
        }
        return ListView.separated(
          itemCount: chats.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 80),
          itemBuilder: (context, index) {
            final chat = chats[index];
            return _buildChatTile(chat);
          },
        );
      },
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat) {
    return ListTile(
      onTap: () => Navigator.pushNamed(context, ChatDetailScreen.routeName, arguments: chat),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(chat['avatar'] ?? ''),
          ),
          if (chat['unread'] > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: _salmon, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '${chat['unread']}',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      title: Text(chat['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        chat['lastMessage'] ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: chat['unread'] > 0 ? Colors.black87 : Colors.grey),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(chat['time'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          if (chat['unread'] > 0)
            const Icon(Icons.circle, size: 10, color: _salmon),
        ],
      ),
    );
  }

  Widget _buildChatEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(Translator.t('no_messages'), style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  // --- ORDERS LOGIC ---

  Widget _buildOrdersList() {
    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        final orders = MockFirebase().allOrders;
        if (orders.isEmpty) {
          return _buildOrderEmptyState();
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return _buildOrderCard(orders[index], index % 2 == 0);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isEven) {
    final List items = order['items'] as List;
    final firstItem = items.isNotEmpty ? items[0]['product'] : null;
    final images = firstItem != null ? firstItem['images'] as List : [];
    final img = images.isNotEmpty ? images[0] : '';
    final date = _formatDate(order['date']);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, OrderDetailScreen.routeName, arguments: order['id']),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: img.isNotEmpty 
                          ? Image.network(img, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.grey))
                          : const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('ID: ${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                              _buildStatusBadge(order['status']),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('${items.length} ${Translator.t('articles')}', style: const TextStyle(fontWeight: FontWeight.bold, color: _navy, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(date, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.grey[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(Translator.t('total'), style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const SizedBox(height: 2),
                        Text('${(order['total'] as num).toStringAsFixed(0)} XAF', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _navy)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, OrderDetailScreen.routeName, arguments: order['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEven ? _salmon : _navy,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(Translator.t('details'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _navy = Color(0xFF0D0D26);

  Widget _buildStatusBadge(String status) {
    Color color;
    String translationKey;
    
    switch (status) {
      case 'En attente': 
        color = Colors.orange; 
        translationKey = 'status_pending';
        break;
      case 'Acceptée': 
        color = Colors.blue; 
        translationKey = 'status_accepted';
        break;
      case 'En confection': 
        color = Colors.purple; 
        translationKey = 'status_confection';
        break;
      case 'Expédiée': 
        color = Colors.teal; 
        translationKey = 'status_shipped';
        break;
      case 'Livrée': 
        color = Colors.green; 
        translationKey = 'status_delivered';
        break;
      default: 
        color = Colors.grey;
        translationKey = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(Translator.t(translationKey).toUpperCase(), 
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
    );
  }

  Widget _buildOrderEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(Translator.t('no_orders'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _navy)),
          ],
        ),
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
}
