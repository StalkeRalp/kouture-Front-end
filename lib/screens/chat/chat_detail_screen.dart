import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import '../../backend/translator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({super.key});

  static const String routeName = '/chat-detail';

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _darkNavy = Color(0xFF0D0D26);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final String chatId = args['chatId'] ?? 'chat1';
    final String vendorName = args['vendorName'] ?? 'Couturier';
    final String vendorAvatar = args['vendorAvatar'] ?? 'https://i.pravatar.cc/150?u=vendor';

    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(vendorAvatar), radius: 18),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vendorName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(Translator.t('online'), style: const TextStyle(fontSize: 11, color: Colors.green)),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(icon: HugeIcon(icon: HugeIcons.strokeRoundedVideo01, color: Colors.black, size: 24.0), onPressed: () {}),
              IconButton(icon: HugeIcon(icon: HugeIcons.strokeRoundedCall, color: Colors.black, size: 24.0), onPressed: () {}),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: MockFirebase().getChatMessages(chatId).length,
                  itemBuilder: (context, index) {
                    final messages = MockFirebase().getChatMessages(chatId);
                    final msg = messages[index];
                    final isMe = msg['senderId'] == 'u1';
                    return _buildMessageBubble(msg, isMe);
                  },
                ),
              ),
              _buildInputArea(chatId),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    final String? text = msg['text'];
    final String? imageUrl = msg['imageUrl'];
    final String time = msg['time'] ?? '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? _salmon : Colors.grey[100],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl.startsWith('http') 
                    ? Image.network(
                        imageUrl, 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          padding: const EdgeInsets.all(20),
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                    : Image.file(
                        File(imageUrl), 
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          padding: const EdgeInsets.all(20),
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                ),
              ),
            if (text != null && text.isNotEmpty)
              Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14, height: 1.4)),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(color: isMe ? Colors.white70 : Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(String chatId) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 10, 30 + MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                await MockFirebase().sendMessage(chatId, null, imageUrl: image.path);
                _scrollToBottom();
              }
            },
            icon: HugeIcon(icon: HugeIcons.strokeRoundedImageAdd01, color: _darkNavy, size: 24),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(30)),
              child: TextField(
                controller: _msgController,
                decoration: InputDecoration(
                  hintText: Translator.t('type_message_hint'),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _handleSend(chatId),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _handleSend(chatId),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: _darkNavy, shape: BoxShape.circle),
              child: HugeIcon(icon: HugeIcons.strokeRoundedSent, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSend(String chatId) async {
    if (_msgController.text.trim().isNotEmpty) {
      final txt = _msgController.text;
      _msgController.clear();
      await MockFirebase().sendMessage(chatId, txt);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 200, 
      duration: const Duration(milliseconds: 300), 
      curve: Curves.easeOut
    );
  }
}
