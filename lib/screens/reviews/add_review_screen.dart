import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import '../../backend/translator.dart';
import 'package:hugeicons/hugeicons.dart';

class AddReviewScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const AddReviewScreen({super.key, required this.product});

  static const String routeName = '/add-review';

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Translator.t('select_rating_error'))),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final user = MockFirebase().currentUser;
    final newReview = {
      'productId': widget.product['id'],
      'userName': user?['name'] ?? 'User',
      'userAvatar': user?['avatar'] ?? 'https://i.pravatar.cc/100',
      'rating': _rating,
      'comment': _commentController.text,
    };

    await MockFirebase().addReview(newReview);

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.pop(context);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: HugeIcon(icon: HugeIcons.strokeRoundedCheckmarkCircle01, color: Color(0xFFFF8C8C), size: 64),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(Translator.t('thank_you'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 10),
            Text(Translator.t('review_submitted'), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: Color(0xFFFF8C8C), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(Translator.t('add_review'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            centerTitle: true,
            leading: IconButton(
              icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, size: 20, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductHeader(),
                const SizedBox(height: 40),
                Center(
                  child: Text(Translator.t('what_is_rate'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                _buildStarRating(),
                const SizedBox(height: 40),
                Text(Translator.t('write_opinion'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                _buildCommentField(),
                const SizedBox(height: 30),
                _buildPhotoSection(),
                const SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductHeader() {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: NetworkImage(widget.product['images']?[0] ?? 'https://via.placeholder.com/150'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product['name'] ?? 'Product',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                widget.product['vendorName'] ?? '',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        int starValue = index + 1;
        return GestureDetector(
          onTap: () => setState(() => _rating = starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: HugeIcon(icon: starValue <= _rating ? HugeIcons.strokeRoundedStars : HugeIcons.strokeRoundedStars, size: 48,
              color: starValue <= _rating ? Colors.amber : Colors.grey[300],),
          ),
        );
      }),
    );
  }

  Widget _buildCommentField() {
    return TextField(
      controller: _commentController,
      maxLines: 6,
      decoration: InputDecoration(
        hintText: Translator.t('enter_opinion_hint'),
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFFF8C8C).withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(20),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(Translator.t('add_photo'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(Translator.t('optional'), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: const Color(0xFFFF8C8C).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFF8C8C).withValues(alpha: 0.1)),
          ),
          child: HugeIcon(icon: HugeIcons.strokeRoundedCameraAdd01, color: Color(0xFFFF8C8C), size: 24.0),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReview,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D0D26),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                Translator.t('submit_review'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
      ),
    );
  }
}
