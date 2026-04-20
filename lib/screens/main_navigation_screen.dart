import 'package:flutter/material.dart';
import '../backend/mock_firebase.dart';
import '../backend/translator.dart';
import 'home/home_screen.dart';
import 'discover/discover_screen.dart';
import 'favorites/favorites_screen.dart';
import 'activities/activities_screen.dart';
import 'profile/profile_screen.dart';
import '../widgets/curved_nav_bar.dart';
import 'package:hugeicons/hugeicons.dart';

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
                  icon: HugeIcons.strokeRoundedHome01,
                  activeIcon: HugeIcons.strokeRoundedHome01,
                ),
                NavItem(
                  label: Translator.t('shop'),
                  icon: HugeIcons.strokeRoundedGridView,
                  activeIcon: HugeIcons.strokeRoundedGridView,
                ),
                NavItem(
                  label: Translator.t('favorites'),
                  icon: HugeIcons.strokeRoundedFavourite,
                  activeIcon: HugeIcons.strokeRoundedFavourite,
                ),
                NavItem(
                  label: Translator.t('activities'),
                  icon: HugeIcons.strokeRoundedMessage01,
                  activeIcon: HugeIcons.strokeRoundedMessage01,
                ),
                NavItem(
                  label: Translator.t('profile'),
                  icon: HugeIcons.strokeRoundedUser,
                  activeIcon: HugeIcons.strokeRoundedUser,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
