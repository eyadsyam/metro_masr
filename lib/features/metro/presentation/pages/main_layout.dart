import 'package:flutter/material.dart';
import 'package:metro_masr/features/metro/presentation/widgets/curved_nav_bar.dart';
import 'subscriptions_screen.dart';
import 'home_screen.dart';
import 'near_screen.dart';
import 'profile_screen.dart';
import 'support_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 2; // Start at Center (Map/Home)

  final List<Widget> _screens = [
    const SupportScreen(),
    const SubscriptionsScreen(),
    const HomeScreen(),
    const NearScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody:
          true, // Important for curved nav bar transparency effect if needed
      body: _screens[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: CurvedNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}
