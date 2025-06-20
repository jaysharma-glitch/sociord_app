import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
import 'package:sociord/screens/profile/profile_scree.dart';
import 'package:sociord/screens/sign_in_sign_up_screen.dart';
import 'package:sociord/screens/onboarding/sign_up_flow.dart';
import 'package:sociord/screens/personality/personality_flow.dart';
import 'package:sociord/screens/profile_pic.dart';

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

/// Root navigator key (needed for full-screen dialogs, etc.)
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// ---------- All application routes (consumed by goRouterProvider) ----------
final List<RouteBase> appRoutes = [
  /// ---- Auth / onboarding ----
  GoRoute(
    path: signInSignUpRoute,
    builder: (_, __) => const SignInSignUpScreen(),
  ),
  GoRoute(
    path: signUpFlowRoute,
    builder: (_, __) => const SignUpFlow(),
  ),
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
  GoRoute(
    path: profilePicRoute,
    builder: (_, __) => const ProfilePicScreen(),
  ),
  GoRoute(
    path: otherGenderRoute,
    builder: (_, __) => const OtherGenderDes(),
  ),
  GoRoute(
    path: loginRoute,
    builder: (_, __) => LoginScreen(),
  ),
  GoRoute(
    path: loginOtpRoute,
    builder: (_, __) => LogInOtpScreen(),
  ),

  /// ---- Bottom-nav shell with four branches ----
  StatefulShellRoute.indexedStack(
    parentNavigatorKey: rootNavigatorKey,
    builder: (_, __, navigationShell) =>
        ScaffoldWithNavBar(navigationShell: navigationShell),
    branches: [
      /// Home
      StatefulShellBranch(routes: [
        GoRoute(
          path: homeRoute,
          builder: (_, __) => HomeScreen(key: ScaffoldWithNavBar.homeScreenKey),
        ),
      ]),

      /// Add
      StatefulShellBranch(routes: [
        GoRoute(
          path: addRoute,
          builder: (_, __) => const AddScreen(),
        ),
      ]),

      /// Explore
      StatefulShellBranch(routes: [
        GoRoute(
          path: exploreRoute,
          builder: (_, __) => const ExploreScreen(),
        ),
      ]),

      /// Profile + nested “Become a Creator”
      StatefulShellBranch(routes: [
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
      ]),
    ],
  ),
];
