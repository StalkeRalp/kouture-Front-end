import 'package:flutter/material.dart';
import '../../backend/translator.dart';
import '../../backend/mock_firebase.dart';
import '../notifications/notifications_screen.dart';
import '../settings/settings_screen.dart';
import '../search/product_search_delegate.dart';
import '../vendor/vendor_profile_screen.dart';
import '../profile/profile_screen.dart';
import '../discover/discover_screen.dart';
import '../cart/cart_screen.dart';
import '../../widgets/product_card.dart';
import '../../widgets/state_widgets.dart';
import '../../widgets/responsive_helper.dart';
import 'package:hugeicons/hugeicons.dart';

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
    _productsFuture = MockFirebase().getRecommendedProducts();
  }

  // 
  // DATA
  // 
  final List<Map<String, String>> _categoriesDataList = [
    {'id': 'men',         'image': 'https://images.unsplash.com/photo-1512484776495-a09d92e87c3b?w=200'},
    {'id': 'women',       'image': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200'},
    {'id': 'kids',        'image': 'https://images.unsplash.com/photo-1471286174890-9c112ffca5b4?w=200'},
    {'id': 'accessories', 'image': 'https://images.unsplash.com/photo-1492707892479-7bc8d5a4ee93?w=200'},
  ];

  // 
  // BUILD
  // 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: MockFirebase(),
          builder: (context, _) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: context.h(16)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: context.w(16)),
                          child: _buildHeader(),
                        ),
                        SizedBox(height: context.h(20)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: context.w(16)),
                          child: _buildSearchBar(),
                        ),
                        SizedBox(height: context.h(20)),
                        _buildHeroBanner(),
                        SizedBox(height: context.h(25)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: context.w(16)),
                          child: _buildSectionHeader(Translator.t('new_arrivals')),
                        ),
                        SizedBox(height: context.h(15)),
                        _buildHorizontalScroll(),
                        SizedBox(height: context.h(25)),
                        _buildBannerDots(),
                        SizedBox(height: context.h(25)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: context.w(16)),
                          child: _buildSectionHeader(Translator.t('categories')),
                        ),
                        SizedBox(height: context.h(15)),
                        _buildCategories(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: context.w(16)),
                          child: _buildSectionHeader(Translator.t('top_trends')),
                        ),
                        SizedBox(height: context.h(15)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: context.w(16)),
                          child: _buildProductGrid(),
                        ),
                        SizedBox(height: context.h(25)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: context.w(16)),
                          child: _buildSectionHeader(Translator.t('recommended_tailors')),
                        ),
                        SizedBox(height: context.h(15)),
                        _buildTailorSuggestions(),
                        SizedBox(height: context.h(30)),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 
  // HEADER
  // 
  Widget _buildHeader() {
    final user = MockFirebase().currentUser;
    final avatarUrl = user?['avatar'] ?? 'https://i.pravatar.cc/150?u=falcon';
    final name = user?['name'] ?? 'Guest';

    return Row(
      children: [
        // Avatar
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName),
          child: Container(
            width: context.w(52),
            height: context.w(52),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _salmon.withValues(alpha: 0.3), width: 2),
              image: DecorationImage(
                image: NetworkImage(avatarUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SizedBox(width: context.w(12)),
        // Texte
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, ProfileScreen.routeName),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Translator.t('welcome_back') + '!',
                style: TextStyle(color: Colors.grey[600], fontSize: context.sp(13)),
              ),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: context.sp(17),
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
                  HugeIcons.strokeRoundedNotification01, 
                  hasBadge: count > 0,
                  badgeCount: count > 0 ? count : null,
                  onTap: () => Navigator.pushNamed(context, NotificationsScreen.routeName),
                );
              }
            ),
            SizedBox(width: context.w(10)),
            // Settings icon
            _buildHeaderIcon(HugeIcons.strokeRoundedSettings01, onTap: () => Navigator.pushNamed(context, SettingsScreen.routeName)),
          ],
    );
  }

  Widget _buildHeaderIcon(dynamic icon, {bool hasBadge = false, int? badgeCount, VoidCallback? onTap}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: context.w(30),
            height: context.w(30),
            decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: HugeIcon(icon: icon, color: Colors.black87, size: context.w(13)),
        ),
        ),
        if (hasBadge)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(context.w(4)),
              decoration: const BoxDecoration(
                color: _salmon,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: badgeCount != null 
                ? Center(
                    child: Text(
                      '$badgeCount',
                      style: TextStyle(color: Colors.white, fontSize: context.sp(7), fontWeight: FontWeight.bold),
                    ),
                  )
                : null,
            ),
          ),
      ],
    );
  }

  Widget _buildHorizontalScroll() {
    final List<Map<String, String>> featured = [
      {'id': 'new_arrivals', 'image': 'https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=400'},
      {'id': 'promotions',  'image': 'https://images.unsplash.com/photo-1441984967741-21338c2b42bc?w=400'},
      {'id': 'Élite',       'image': 'https://images.unsplash.com/photo-1479064566235-aa2742b96a46?w=400'},
      {'id': 'Tradition',   'image': 'https://images.unsplash.com/photo-1544441893-675973e31985?w=400'},
      {'id': 'Mariage',     'image': 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=400'},
    ];

    return SizedBox(
      height: context.h(110),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: featured.length,
        itemBuilder: (context, index) {
          final String titleKey = featured[index]['id']!;
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, DiscoverScreen.routeName),
            child: Container(
              width: context.w(160),
              margin: EdgeInsets.only(right: context.w(12)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: NetworkImage(featured[index]['image']!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: EdgeInsets.all(context.w(12)),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    // Try translating, fallback to ID
                    Translator.t(titleKey).contains(titleKey) ? titleKey : Translator.t(titleKey),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: context.sp(14),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
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
              height: context.h(50),
              padding: EdgeInsets.symmetric(horizontal: context.w(18)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  HugeIcon(icon: HugeIcons.strokeRoundedSearch01, color: Colors.grey[400], size: context.w(18)),
                  SizedBox(width: context.w(10)),
                  Text(
                    Translator.t('search_hint'),
                    style: TextStyle(color: Colors.grey[400], fontSize: context.sp(14)),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Cart icon with badge
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, CartScreen.routeName),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              HugeIcon(icon: HugeIcons.strokeRoundedShoppingCart01, size: context.w(22), color: Colors.black87),
              Positioned(
                right: -4,
                top: -4,
                child: AnimatedBuilder(
                  animation: MockFirebase(),
                  builder: (context, _) {
                    final count = MockFirebase().cartItems.length;
                    if (count == 0) return const SizedBox();
                    return Container(
                      width: context.w(18),
                      height: context.w(18),
                      decoration: const BoxDecoration(
                        color: _salmon,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.sp(10),
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
      height: context.h(200),
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
                      Colors.black.withValues(alpha: 0.55),
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.sp(26),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.h(14)),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, DiscoverScreen.routeName),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _salmon,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: context.w(22), vertical: context.h(10)),
                        elevation: 0,
                      ),
                      child: Text(
                        Translator.t('shop_now'),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: context.sp(13),
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
          height: context.h(8),
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: context.sp(18),
            color: Colors.black,
          ),
        ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, DiscoverScreen.routeName),
            child: Container(
              padding: EdgeInsets.all(context.w(6)),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.15),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: context.w(18), color: Colors.black87),
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
      height: context.h(120),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categoriesDataList.length,
        itemBuilder: (context, index) {
          final cat = _categoriesDataList[index];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, DiscoverScreen.routeName),
            child: Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Column(
                children: [
                  Container(
                    width: context.w(68),
                    height: context.w(68),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _salmon.withValues(alpha: 0.4), width: 2),
                      image: DecorationImage(
                        image: NetworkImage(cat['image']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: context.h(8)),
                  Text(
                    Translator.t(cat['id']!),
                    style: TextStyle(fontSize: context.sp(12), color: Colors.black87),
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

  Widget _buildTailorSuggestions() {
    return FutureBuilder<List<dynamic>>(
      future: MockFirebase().getSuggestedTailors(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: context.h(170),
            child: const KoutureLoadingState(),
          );
        }
        
        final tailors = snapshot.data ?? [];
        if (tailors.isEmpty) return const SizedBox();

        return SizedBox(
          height: context.h(170),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tailors.length,
            itemBuilder: (context, index) {
              final tailor = tailors[index];
              return _buildTailorCard(tailor);
            },
          ),
        );
      },
    );
  }

  Widget _buildTailorCard(Map<String, dynamic> tailor) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, VendorProfileScreen.routeName, arguments: tailor['id']),
      child: Container(
        width: context.w(140),
        margin: EdgeInsets.only(right: context.w(16), bottom: context.h(10)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      image: DecorationImage(
                        image: NetworkImage(tailor['coverImage'] ?? ''),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: AnimatedBuilder(
                      animation: MockFirebase(),
                      builder: (context, _) {
                        final bool isFav = MockFirebase().isFavorite(tailor['id'].toString());
                        return GestureDetector(
                          onTap: () => MockFirebase().toggleFavorite(tailor['id'].toString()),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: HugeIcon(icon: isFav ? HugeIcons.strokeRoundedFavourite : HugeIcons.strokeRoundedFavourite, color: isFav ? _salmon : Colors.grey,
                              size: 16,),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      tailor['name'] ?? '',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: context.sp(13)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.h(4)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(icon: HugeIcons.strokeRoundedStars, color: Colors.amber, size: context.w(10)),
                        SizedBox(width: context.w(2)),
                        Text(
                          '${tailor['rating']}',
                          style: TextStyle(fontSize: context.sp(10), fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: context.w(6)),
                        Text(
                          '${tailor['publicationCount']} pub.',
                          style: TextStyle(fontSize: context.sp(10), color: Colors.grey[600]),
                        ),
                      ],
                    ),
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
  // PRODUCT GRID
  // 
  Widget _buildProductGrid() {
    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        return FutureBuilder<List<dynamic>>(
          // Re-fetch when user auth state changes so recommendations update
          future: MockFirebase().getRecommendedProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),
                child: KoutureLoadingState(message: Translator.t('loading_products')),
              );
            }
            if (snapshot.hasError) {
              return KoutureErrorState(
                message: Translator.t('error_fetching_products'),
                onRetry: () {
                  setState(() {
                    _productsFuture = MockFirebase().getRecommendedProducts();
                  });
                },
              );
            }

            final products = snapshot.data ?? [];
            if (products.isEmpty) {
              return KoutureEmptyState(
                title: Translator.t('no_products'),
                message: Translator.t('no_recommended_products'),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: context.screenWidth > 600 ? 3 : 2,
                mainAxisSpacing: context.h(25),
                crossAxisSpacing: context.w(14),
                childAspectRatio: 0.6,
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
      },
    );
  }
}