import 'package:flutter/material.dart';
import '../../backend/translator.dart';
import '../../backend/mock_firebase.dart';
import '../../widgets/product_card.dart';
import '../settings/settings_screen.dart';
import '../profile/profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../search/search_screen.dart';
import '../search/search_results_screen.dart';
import '../cart/cart_summary_screen.dart';
import 'package:hugeicons/hugeicons.dart';


class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  static const String routeName = '/discover';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildTopRow(context),
                    const SizedBox(height: 10),
                    Text(
                      Translator.t('discover'),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    _buildSearchBar(context),
                    const SizedBox(height: 25),
                    Text(
                      Translator.t('categories'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 15),
                    _buildCategories(),
                    const SizedBox(height: 25),
                    _buildProductGrid(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopRow(BuildContext context) {
    final user = MockFirebase().currentUser;
    final avatarUrl = user?['avatar'] ?? 'https://i.pravatar.cc/150?u=falcon';
    final name = user?['name'] ?? 'User';

    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(avatarUrl),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Translator.t('welcome_back') + '!',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
        const Spacer(),
        AnimatedBuilder(
          animation: MockFirebase(),
          builder: (context, _) {
            final count = MockFirebase().unreadNotificationsCount;
            return _buildHeaderIcon(
              HugeIcons.strokeRoundedNotification01, 
              hasBadge: count > 0,
              badgeCount: count > 0 ? count : null,
              onTap: () => Navigator.pushNamed(context, NotificationsScreen.routeName),
            );
          }
        ),
        const SizedBox(width: 8),
        _buildHeaderIcon(HugeIcons.strokeRoundedSettings01, onTap: () => Navigator.pushNamed(context, SettingsScreen.routeName)),
      ],
    );
  }

  Widget _buildHeaderIcon(dynamic icon, {bool hasBadge = false, int? badgeCount, VoidCallback? onTap}) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: HugeIcon(icon: icon, color: Colors.black, size: 20),
        ),
        ),
        if (hasBadge)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Color(0xFFFF8C8C),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: badgeCount != null 
                ? Center(
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold),
                    ),
                  )
                : null,
            ),
          ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, SearchScreen.routeName),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: Color(0xFF0D0D26), size: 22),
                  const SizedBox(width: 12),
                  Text(
                    Translator.t('search_hint'),
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Color(0xFF0D0D26), shape: BoxShape.circle),
                    child: HugeIcon(icon: HugeIcons.strokeRoundedFilter, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, CartSummaryScreen.routeName),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              HugeIcon(icon: HugeIcons.strokeRoundedShoppingCart01, size: 28, color: Colors.black),
              Positioned(
                right: -4,
                top: -4,
                child: AnimatedBuilder(
                  animation: MockFirebase(),
                  builder: (context, _) {
                    final count = MockFirebase().cartItems.length;
                    if (count == 0) return const SizedBox();
                    return Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF8C8C),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'id': 'men', 'image': 'https://images.unsplash.com/photo-1512484776495-a09d92e87c3b?w=200'},
      {'id': 'women', 'image': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200'},
      {'id': 'kids', 'image': 'https://images.unsplash.com/photo-1471286174890-9c112ffca5b4?w=200'},
      {'id': 'accessories', 'image': 'https://images.unsplash.com/photo-1492707892479-7bc8d5a4ee93?w=200'},
    ];


    return SizedBox(
      height: 115,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isEven = index % 2 == 0;
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, SearchResultsScreen.routeName, arguments: categories[index]['id']),
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: isEven ? const Color(0xFFFF8C8C) : const Color(0xFF0D0D26), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.grey[100],
                      backgroundImage: NetworkImage(categories[index]['image']!),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Translator.t(categories[index]['id']!),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return FutureBuilder<List<dynamic>>(
      future: MockFirebase().getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(20.0),
            child: CircularProgressIndicator(color: Color(0xFFFF8C8C)),
          ));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No products available'));
        }

        final products = snapshot.data!;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 25,
            crossAxisSpacing: 14,
            childAspectRatio: 0.6,
          ),
          itemBuilder: (context, index) {
            final p = products[index] as Map<String, dynamic>;
            return ProductCard(
              product: p,
              onFavoriteTap: () {},
              onAddToCartTap: () {},
              heroPrefix: 'discover',
            );
          },
        );
      },
    );
  }
}

