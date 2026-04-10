import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  static const String routeName = '/chat-list';
  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _darkNavy = Color(0xFF0D0D26);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: MockFirebase().getUser('u1'),
        builder: (context, userSnap) {
          // We'll use the chats data from the JSON - access via a workaround through allProducts filtered approach
          // For now directly load from backend chat data
          return _buildChatList(context);
        },
      ),
    );
  }

  Widget _buildChatList(BuildContext context) {
    // Load chat data from the chats list in products.json
    return FutureBuilder<List<dynamic>>(
      future: _getChats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: _salmon));
        }

        final chats = snapshot.data ?? [];

        if (chats.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          children: [
            // Activities tabs
            Container(
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildTab('Messages', true)),
                  Expanded(child: _buildTab('Commandes', false, onTap: () => Navigator.pushNamed(context, '/orders'))),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: chats.length,
                separatorBuilder: (_, __) => const Divider(height: 20),
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return _buildChatTile(context, chat);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<dynamic>> _getChats() async {
    // Simulate loading chats from MockFirebase
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      {
        'id': 'ch1',
        'vendorName': 'Tailleur Du Roi',
        'vendorId': 'v2',
        'vendorAvatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&q=80',
        'lastMessage': 'Votre costume est prêt pour l\'essayage.',
        'lastMessageAt': '11:15',
        'unreadCount': 1,
      },
      {
        'id': 'ch2',
        'vendorName': 'Boutique Elegance',
        'vendorId': 'v1',
        'vendorAvatar': 'https://images.unsplash.com/photo-1567401893414-76b7b1e5a7a5?w=100&q=80',
        'lastMessage': 'Merci pour votre achat ! 😊',
        'lastMessageAt': '15:00',
        'unreadCount': 0,
      },
    ];
  }

  Widget _buildTab(String label, bool active, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)] : [],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: active ? _darkNavy : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, Map<String, dynamic> chat) {
    final hasUnread = (chat['unreadCount'] ?? 0) > 0;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, ChatDetailScreen.routeName, arguments: {
        'chatId': chat['id'],
        'vendorName': chat['vendorName'],
        'vendorAvatar': chat['vendorAvatar'],
      }),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(chat['vendorAvatar']),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(chat['vendorName'], style: TextStyle(fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600, fontSize: 16)),
                    Text(chat['lastMessageAt'], style: TextStyle(color: hasUnread ? _salmon : Colors.grey[500], fontSize: 12, fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(chat['lastMessage'], maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: hasUnread ? Colors.black87 : Colors.grey[600], fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal)),
                    ),
                    if (hasUnread)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: _salmon, shape: BoxShape.circle),
                        child: Text('${chat['unreadCount']}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text('Aucune conversation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 10),
          Text('Contactez un vendeur depuis une fiche produit', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/discover'),
            style: ElevatedButton.styleFrom(backgroundColor: _darkNavy, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('EXPLORER LES PRODUITS', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
