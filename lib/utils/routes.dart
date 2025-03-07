import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import 'package:sociord/widgets/scaffold_with_nav.dart';

// ✅ Define route names as constants
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
const String becomeACreator = '/profile/becomeACreator';

// ✅ Configure GoRouter with centralized route names
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GoRouter router = GoRouter(
  initialLocation: signInSignUpRoute,
  navigatorKey: rootNavigatorKey,
  routes: [
    GoRoute(
      path: signInSignUpRoute,
      builder: (context, state) => const SignInSignUpScreen(),
    ),
    GoRoute(
      path: signUpFlowRoute,
      builder: (context, state) => const SignUpFlow(),
    ),
    GoRoute(
      path: locationSearchRoute,
      builder: (context, state) => const LocationSearch(),
    ),
    GoRoute(
      path: finalOnboardingRoute,
      builder: (context, state) => const FinalOnboardingScreen(),
    ),
    GoRoute(
      path: personalityFlowRoute,
      builder: (context, state) => const PersonalityFlow(),
    ),
    GoRoute(
      path: profilePicRoute,
      builder: (context, state) => const ProfilePicScreen(),
    ),
    GoRoute(
      path: otherGenderRoute,
      builder: (context, state) => const OtherGenderDes(),
    ),
    GoRoute(
      path: loginRoute,
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: loginOtpRoute,
      builder: (context, state) => LogInOtpScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: homeRoute,
            builder: (context, state) => const HomeScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: addRoute,
            builder: (context, state) => const AddScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: exploreRoute,
            builder: (context, state) => const ExploreScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: profileRoute,
            builder: (context, state) => ProfileScreen(),
            routes: [
              GoRoute(
                path: 'becomeACreator', // Nested route
                parentNavigatorKey: rootNavigatorKey,
                builder: (context, state) => const BecomeACreator(),
              ),
            ],
          ),
        ]),
      ],
    ),
  ],
);
