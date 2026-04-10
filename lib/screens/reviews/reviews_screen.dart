import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';
import 'add_review_screen.dart';

class ReviewsScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ReviewsScreen({super.key, required this.product});

  static const String routeName = '/reviews';

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', '5 stars', '4 stars', '3 stars', '2 stars', '1 star'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: MockFirebase(),
        builder: (context, _) {
          return FutureBuilder<List<dynamic>>(
            future: MockFirebase().getReviewsByProductId(widget.product['id'].toString()),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C8C)));
              }

              final reviews = snapshot.data ?? [];
              final filteredReviews = _filterReviews(reviews);

              return Column(
                children: [
                  _buildRatingSummary(reviews),
                  _buildFilters(),
                  Expanded(
                    child: filteredReviews.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: filteredReviews.length,
                            itemBuilder: (context, index) {
                              return _buildReviewCard(filteredReviews[index]);
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  List<dynamic> _filterReviews(List<dynamic> reviews) {
    if (_selectedFilter == 'All') return reviews;
    int target = int.parse(_selectedFilter.split(' ')[0]);
    return reviews.where((r) => (r['rating'] as num).toInt() == target).toList();
  }

  Widget _buildRatingSummary(List<dynamic> reviews) {
    double avgRating = reviews.isEmpty ? 0 : reviews.map((r) => r['rating'] as num).reduce((a, b) => a + b) / reviews.length;
    int totalReviews = reviews.length;

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF8C8C).withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  avgRating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) => Icon(
                    index < avgRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  )),
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalReviews reviews',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Container(height: 60, width: 1, color: Colors.grey[300]),
          const SizedBox(width: 20),
          Expanded(
            flex: 3,
            child: Column(
              children: List.generate(5, (index) {
                int star = 5 - index;
                int count = reviews.where((r) => (r['rating'] as num).toInt() == star).length;
                double percent = totalReviews == 0 ? 0 : count / totalReviews;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$star', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: percent,
                          backgroundColor: Colors.white,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF8C8C)),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20, bottom: 20),
      child: Row(
        children: _filters.map((filter) {
          bool isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedFilter = filter),
              selectedColor: const Color(0xFFFF8C8C),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: const Color(0xFFFDECEC),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(review['userAvatar'] ?? 'https://i.pravatar.cc/100'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['userName'] ?? 'Kouture User',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      review['date'] ?? 'Just now',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) => Icon(
                  Icons.star,
                  size: 14,
                  color: index < (review['rating'] as num) ? Colors.amber : Colors.grey[300],
                )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'] ?? '',
            style: const TextStyle(color: Colors.black87, height: 1.5, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                '${review['likes']} helpful',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('Helpful?', style: TextStyle(color: Color(0xFFFF8C8C), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          Divider(color: Colors.grey.withOpacity(0.1), height: 30),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No reviews for this filter yet',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AddReviewScreen.routeName, arguments: widget.product),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D0D26),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text(
              'WRITE A REVIEW',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
        ),
      ),
    );
  }
}
