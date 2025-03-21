// lib/widgets/scaffold_with_nav.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/screens/home/home_screen.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import '../utils/routes.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  static final GlobalKey<HomeScreenState> homeScreenKey = GlobalKey(); // ✅

  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: kAppBlack, width: 0.1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _getCurrentIndex(location),
          onTap: (index) {
            final currentIndex = _getCurrentIndex(location);
            if (index == 0 && currentIndex == 0) {
              // We're already on Home, so scroll to top
              ScaffoldWithNavBar.homeScreenKey.currentState?.scrollToTop();
            } else {
              switch (index) {
                case 0:
                  context.go(homeRoute);
                  break;
                case 1:
                  context.go(addRoute);
                  break;
                case 2:
                  context.go(exploreRoute);
                  break;
                case 3:
                  context.go(profileRoute);
                  break;
              }
            }
          },
          backgroundColor: kAppWhite,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kAppPurple,
          unselectedItemColor: kAppBlack,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          items: [
            BottomNavigationBarItem(
                icon: Image.asset(kHome),
                activeIcon: Image.asset(kHomeSelect),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Image.asset(kAdd),
                activeIcon: Image.asset(kAdd),
                label: 'Add'),
            BottomNavigationBarItem(
                icon: Image.asset(kExplore),
                activeIcon: Image.asset(kExploreSelect),
                label: 'Explore'),
            BottomNavigationBarItem(
                icon: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(
                    kProfilePic,
                    height: 33,
                    width: 33,
                  ),
                ),
                activeIcon: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: kAppPurple,
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.asset(
                      kProfilePic,
                      height: 28,
                      width: 28,
                    ),
                  ),
                ),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }

  int _getCurrentIndex(String location) {
    if (location.startsWith(profileRoute)) return 3;
    if (location.startsWith(exploreRoute)) return 2;
    if (location.startsWith(addRoute)) return 1;
    return 0;
  }
}
