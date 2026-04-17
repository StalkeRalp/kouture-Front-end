import 'package:flutter/material.dart';
import '../backend/mock_firebase.dart';
import '../backend/translator.dart';
import 'home/home_screen.dart';
import 'discover/discover_screen.dart';
import 'favorites/favorites_screen.dart';
import 'activities/activities_screen.dart';
import 'profile/profile_screen.dart';
import '../widgets/curved_nav_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  static const String routeName = '/main-nav';

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const DiscoverScreen(),
    const FavoritesScreen(),
    const ActivitiesScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MockFirebase(),
      builder: (context, _) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            body: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
            extendBody: true, // Pour que le contenu aille derrière la bulle flottante
            bottomNavigationBar: CurvedNavBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: [
                NavItem(
                  label: Translator.t('home'),
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                ),
                NavItem(
                  label: Translator.t('shop'),
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view_rounded,
                ),
                NavItem(
                  label: Translator.t('favorites'),
                  icon: Icons.favorite_outline,
                  activeIcon: Icons.favorite,
                ),
                NavItem(
                  label: Translator.t('activities'),
                  icon: Icons.forum_outlined,
                  activeIcon: Icons.forum,
                ),
                NavItem(
                  label: Translator.t('profile'),
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
