import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/utils/routes.dart'; // for path constants
import 'package:sociord/screens/home/home_screen.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell, // <—
  });

  /// The shell that keeps every tab’s own navigation stack.
  final StatefulNavigationShell navigationShell;

  /// Exposed so HomeScreen can scroll to top.
  static final GlobalKey<HomeScreenState> homeScreenKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell, // <— renders the active branch
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == currentIndex && index == 0) {
            homeScreenKey.currentState?.scrollToTop();
          } else {
            // Keeps each tab’s history; doesn’t rebuild the whole shell
            navigationShell.goBranch(index, initialLocation: false);
          }
        },
        backgroundColor: kAppWhite,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kAppPurple,
        unselectedItemColor: kAppBlack,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: _navBarItems,
      ),
    );
  }

  List<BottomNavigationBarItem> get _navBarItems => [
        BottomNavigationBarItem(
          icon: Image.asset(kHome),
          activeIcon: Image.asset(kHomeSelect),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(kAdd),
          activeIcon: Image.asset(kAdd),
          label: 'Add',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(kExplore),
          activeIcon: Image.asset(kExploreSelect),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset(kProfilePic, height: 33, width: 33),
          ),
          activeIcon: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kAppPurple, width: 3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: Image.asset(kProfilePic, height: 28, width: 28),
            ),
          ),
          label: 'Profile',
        ),
      ];
}
