import 'package:flutter/material.dart';
import '../backend/mock_firebase.dart';
import '../backend/translator.dart';
import 'home/home_screen.dart';
import 'discover/discover_screen.dart';
import 'favorites/favorites_screen.dart';
import 'activities/activities_screen.dart';
import 'profile/profile_screen.dart';

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
        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFFFF8C8C),
            unselectedItemColor: Colors.grey[400],
            type: BottomNavigationBarType.fixed,
            elevation: 10,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home),
                label: Translator.t('home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.grid_view_outlined),
                activeIcon: const Icon(Icons.grid_view_rounded),
                label: Translator.t('shop'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.favorite_outline),
                activeIcon: const Icon(Icons.favorite),
                label: Translator.t('favorites'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.forum_outlined),
                activeIcon: const Icon(Icons.forum),
                label: Translator.t('activities'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outline),
                activeIcon: const Icon(Icons.person),
                label: Translator.t('profile'),
              ),
            ],
          ),
        );
      },
    );
  }
}
