import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/utils/routes.dart'; // for path constants
import 'package:sociord/screens/home/home_screen.dart';
import 'package:sociord/widgets/common/profile_avatar.dart';

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
    // Adjust currentIndex to account for Add button being a modal
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell, // <— renders the active branch
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 1) {
            // Add button - navigate to full-screen modal
            context.go(addRoute);
          } else if (index == currentIndex && index == 0) {
            homeScreenKey.currentState?.scrollToTop();
          } else {
            // Keeps each tab's history; doesn't rebuild the whole shell
            // Adjust index for Add button (index 1 is Add, so shift other indices)
            final adjustedIndex = index > 1 ? index - 1 : index;
            navigationShell.goBranch(adjustedIndex, initialLocation: false);
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
      icon: ProfileAvatar(imageUrl: kProfilePic, size: 33),
      activeIcon: ProfileAvatar(
        imageUrl: kProfilePic,
        size: 28,
        showBorder: true,
        borderWidth: 3,
        borderColor: kAppPurple,
      ),
      label: 'Profile',
    ),
  ];
}
