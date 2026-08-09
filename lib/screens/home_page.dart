import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widget/custom_navigation_bar.dart';
import '../providers/user_provider.dart';
import 'home_tab.dart';
import 'guest_profile.dart';
import 'map_screen.dart';
import 'profile.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isAnonymous = userProvider.user.isAnonymous;

    // Define the pages for the IndexedStack
    final List<Widget> pages = [
      HomeTab(onTabChange: _onTabTapped),
      const MapScreen(showBottomNav: false),
      isAnonymous
          ? const GuestProfilePage()
          : const UserProfilePage(showBottomNav: false),
      const SettingsPage(showBackButton: false),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
