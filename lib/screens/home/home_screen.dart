import 'package:flutter/material.dart';
import '../../widgets/product_card.dart';
import '../settings/settings_screen.dart';
import '../../backend/mock_firebase.dart';
import '../search/product_search_delegate.dart';
import '../notifications/notifications_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentBannerIndex = 2;
  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _lightBg = Color(0xFFF8F8F8);

  late Future<List<dynamic>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = MockFirebase().getProducts();
  }

  // 
  // DATA
  // 
  final List<Map<String, String>> _categories = [
    {'name': 'Men',        'image': 'https://images.unsplash.com/photo-1512484776495-a09d92e87c3b?w=200'},
    {'name': 'Women',      'image': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200'},
    {'name': 'Kids',       'image': 'https://images.unsplash.com/photo-1471286174890-9c112ffca5b4?w=200'},
    {'name': 'Accessories','image': 'https://images.unsplash.com/photo-1492707892479-7bc8d5a4ee93?w=200'},
  ];

  // 
  // BUILD
  // 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: SafeArea(
        child: Column(
          children: [
            //  Scrollable content 
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildHeader(),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSearchBar(),
                    ),
                    const SizedBox(height: 20),
                    _buildHeroBanner(),
                    const SizedBox(height: 20),
                    //  Dots indicateur 
                    _buildBannerDots(),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSectionHeader('Category'),
                    ),
                    const SizedBox(height: 15),
                    _buildCategories(),
                    const SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildSectionHeader('Top Tendances'),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildProductGrid(),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 
  // HEADER
  // 
  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        final user = MockFirebase().currentUser;
        final avatarUrl = user?['avatar'] ?? 'https://i.pravatar.cc/150?u=falcon';
        final name = user?['name'] ?? 'Guest';

        return Row(
          children: [
            // Avatar
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _salmon.withOpacity(0.3), width: 2),
                  image: DecorationImage(
                    image: NetworkImage(avatarUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Texte
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back!',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Notification icon
            AnimatedBuilder(
              animation: MockFirebase(),
              builder: (context, _) {
                final count = MockFirebase().unreadNotificationsCount;
                return _buildHeaderIcon(
                  Icons.notifications_outlined, 
                  hasBadge: count > 0,
                  badgeCount: count > 0 ? count : null,
                  onTap: () => Navigator.pushNamed(context, NotificationsScreen.routeName),
                );
              }
            ),
            const SizedBox(width: 10),
            // Settings icon
            _buildHeaderIcon(Icons.settings_outlined, onTap: () => Navigator.pushNamed(context, SettingsScreen.routeName)),
          ],
        );
      }
    );
  }

  Widget _buildHeaderIcon(IconData icon, {bool hasBadge = false, int? badgeCount, VoidCallback? onTap}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.black87, size: 22),
        ),
        ),
        if (hasBadge)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: _salmon,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: badgeCount != null 
                ? Center(
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  )
                : null,
            ),
          ),
      ],
    );
  }

  // 
  // SEARCH BAR
  // 
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              showSearch(context: context, delegate: ProductSearchDelegate());
            },
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[400], size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'What are you looking for...',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Cart icon with badge
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/cart'),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 28, color: Colors.black87),
              Positioned(
                right: -4,
                top: -4,
                child: AnimatedBuilder(
                  animation: MockFirebase(),
                  builder: (context, _) {
                    final count = MockFirebase().cartItems.length;
                    if (count == 0) return const SizedBox();
                    return Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: _salmon,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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

  // 
  // HERO BANNER CAROUSEL
  // 
  Widget _buildHeroBanner() {
    final promos = MockFirebase().promotions;
    if (promos.isEmpty) return const SizedBox();

    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: promos.length,
        onPageChanged: (index) => setState(() => _currentBannerIndex = index),
        itemBuilder: (context, index) {
          final p = promos[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: NetworkImage(p['image'] ?? ''),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      Colors.black.withOpacity(0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p['title'] ?? 'New Trend 2026',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/discover'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _salmon,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                        elevation: 0,
                      ),
                      child: const Text(
                        'SHOP NOW',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 
  // BANNER DOTS
  // 
  Widget _buildBannerDots() {
    final promoCount = MockFirebase().promotions.length;
    if (promoCount <= 1) return const SizedBox();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(promoCount, (i) {
        final bool active = i == _currentBannerIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? _salmon : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // 
  // SECTION HEADER
  // 
  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/discover'),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(Icons.chevron_right, size: 20, color: Colors.black87),
            ),
          ),
      ],
    );
  }

  // 
  // CATEGORIES
  // 
  Widget _buildCategories() {
    return SizedBox(
      height: 105,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/discover'),
            child: Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _salmon.withOpacity(0.4), width: 2),
                      image: DecorationImage(
                        image: NetworkImage(_categories[index]['image']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _categories[index]['name']!,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 
  // PRODUCT GRID
  // 
  Widget _buildProductGrid() {
    return FutureBuilder<List<dynamic>>(
      future: _productsFuture,
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
            mainAxisSpacing: 18,
            crossAxisSpacing: 14,
            childAspectRatio: 0.68,
          ),
          itemBuilder: (context, index) {
            final p = products[index] as Map<String, dynamic>;
            return ProductCard(
              product: p,
              onFavoriteTap: () {},
              onAddToCartTap: () {},
              heroPrefix: 'home',
            );
          },
        );
      },
    );
  }
}