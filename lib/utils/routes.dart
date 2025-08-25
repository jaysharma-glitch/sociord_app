import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/widgets/profile/homePagePosts/profile_hero.dart';

// screens
import 'package:sociord/screens/add/add_screen.dart';
import 'package:sociord/screens/explore/explore_screen.dart';
import 'package:sociord/screens/home/home_screen.dart';
import 'package:sociord/screens/log_in_otp_screen.dart';
import 'package:sociord/screens/login_in_screen.dart';
import 'package:sociord/screens/onboarding/final_onboarding_screen.dart';
import 'package:sociord/screens/onboarding/location_search.dart';
import 'package:sociord/screens/onboarding/other_gender.dart';
import 'package:sociord/screens/profile/become_a_creator.dart';
import 'package:sociord/screens/profile/buddy_profile_screen.dart';
import 'package:sociord/screens/profile/profile_screen.dart';
import 'package:sociord/screens/sign_in_sign_up_screen.dart';
import 'package:sociord/screens/onboarding/sign_up_flow.dart';
import 'package:sociord/screens/personality/personality_flow.dart';
import 'package:sociord/screens/profile_pic.dart';
import 'package:sociord/widgets/feed/feed_sheet.dart';
import 'package:sociord/widgets/feed/feed_data.dart';
import 'package:sociord/widgets/feed/feed_item.dart';
import 'package:sociord/widgets/feed/feed_type.dart';

// shell
import 'package:sociord/widgets/scaffold_with_nav.dart';

/// ---------- Path constants ----------
const String signInSignUpRoute = '/signInSignup';
const String signUpFlowRoute = '/signUp';
const String locationSearchRoute = '/locationSearch';
const String finalOnboardingRoute = '/finalOnboarding';
const String personalityFlowRoute = '/personalityFlow';
const String profilePicRoute = '/profilePic';
const String otherGenderRoute = '/otherGender';
const String loginRoute = '/login';
const String loginOtpRoute = '/loginOtp';

const String homeRoute = '/home';
const String addRoute = '/add';
const String exploreRoute = '/explore';
const String profileRoute = '/profile';
const String buddyProfileRoute = '/home/buddy-profile'; // Nested under home
const String buddyFeedRoute = '/buddy-feed';

/// Root navigator key (needed for full-screen dialogs, etc.)
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Helper function to parse relationship string to enum
RelationshipType _parseRelationship(String relationship) {
  switch (relationship.toLowerCase()) {
    case 'buddy':
      return RelationshipType.buddy;
    case 'following':
      return RelationshipType.following;
    case 'subscribed':
      return RelationshipType.subscribed;
    default:
      return RelationshipType.none;
  }
}

/// ---------- All application routes (consumed by goRouterProvider) ----------
final List<RouteBase> appRoutes = [
  /// ---- Auth / onboarding ----
  GoRoute(
    path: signInSignUpRoute,
    builder: (_, __) => const SignInSignUpScreen(),
  ),
  GoRoute(path: signUpFlowRoute, builder: (_, __) => const SignUpFlow()),
  GoRoute(
    path: locationSearchRoute,
    builder: (_, __) => const LocationSearch(),
  ),
  GoRoute(
    path: finalOnboardingRoute,
    builder: (_, __) => const FinalOnboardingScreen(),
  ),
  GoRoute(
    path: personalityFlowRoute,
    builder: (_, __) => const PersonalityFlow(),
  ),
  GoRoute(path: profilePicRoute, builder: (_, __) => const ProfilePicScreen()),
  GoRoute(path: otherGenderRoute, builder: (_, __) => const OtherGenderDes()),
  GoRoute(path: loginRoute, builder: (_, __) => LoginScreen()),
  GoRoute(path: loginOtpRoute, builder: (_, __) => LogInOtpScreen()),

  /// Buddy Feed Route (outside shell for navigation from anywhere)
  GoRoute(
    path: buddyFeedRoute,
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};

      // Create FeedData for buddy feed
      final feedData = FeedData.buddy(
        items: [
          FeedItem(
            imagePath: extra['imagePath'] ?? '',
            title: extra['username'] ?? '',
            caption: extra['caption'] ?? '',
            profileImage: extra['profileImage'] ?? '',
            userName: extra['username'] ?? '',
          ),
        ],
        userName: extra['username'] ?? '',
        profileImage: extra['profileImage'] ?? '',
      );

      return FeedSheet(feedData: feedData, initialIndex: 0);
    },
  ),

  /// ---- Bottom-nav shell with four branches ----
  StatefulShellRoute.indexedStack(
    parentNavigatorKey: rootNavigatorKey,
    builder:
        (_, __, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
    branches: [
      /// Home
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: homeRoute,
            builder:
                (_, __) => HomeScreen(key: ScaffoldWithNavBar.homeScreenKey),
            routes: [
              /// Buddy Profile Route (nested under home to keep bottom nav)
              GoRoute(
                path: 'buddy-profile',
                builder: (context, state) {
                  final username = state.uri.queryParameters['username'] ?? '';
                  final profileImage =
                      state.uri.queryParameters['profileImage'] ?? '';
                  final relationship =
                      state.uri.queryParameters['relationship'] ?? 'none';

                  return BuddyProfileScreen(
                    username: username,
                    profileImage: profileImage,
                    relationship: _parseRelationship(relationship),
                  );
                },
              ),
            ],
          ),
        ],
      ),

      /// Add
      StatefulShellBranch(
        routes: [
          GoRoute(path: addRoute, builder: (_, __) => const AddScreen()),
        ],
      ),

      /// Explore
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: exploreRoute,
            builder: (_, __) => const ExploreScreen(),
          ),
        ],
      ),

      /// Profile + nested “Become a Creator”
      StatefulShellBranch(
        routes: [
          GoRoute(
            path: profileRoute,
            builder: (_, __) => ProfileScreen(),
            routes: [
              GoRoute(
                path: 'becomeACreator',
                parentNavigatorKey: rootNavigatorKey,
                builder: (_, __) => const BecomeACreator(),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
