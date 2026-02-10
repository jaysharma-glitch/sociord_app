import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sociord/provider/auth_notifier.dart';
import 'package:sociord/provider/onboarding_provider.dart';
import 'package:sociord/utils/routes.dart';

/// Cached so we never recreate the router when auth changes (e.g. after login during sign-up).
/// Recreating would use initialLocation and send user to home, skipping OTP/onboarding.
GoRouter? _cachedRouter;

final goRouterProvider = Provider<GoRouter?>((ref) {
  ref.watch(onboardingProvider);
  final authState = ref.watch(authProvider);

  if (authState.isLoading || !authState.hasValue) {
    return null; // Delay until auth has loaded
  }

  if (_cachedRouter != null) {
    return _cachedRouter;
  }

  final isLoggedIn = authState.value!.isLoggedIn;
  _cachedRouter = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: isLoggedIn ? homeRoute : signInSignUpRoute,
    debugLogDiagnostics: true,
    refreshListenable:
        GoRouterRefreshStream(ref.watch(authProvider.notifier).stream),
    redirect: (_, state) {
      final location = state.matchedLocation;
      final auth = ref.read(authProvider);
      if (auth.isLoading || !auth.hasValue) return null;
      final isLoggedIn = auth.value!.isLoggedIn;

      final isAuthOrOnboarding = [
        signInSignUpRoute,
        loginRoute,
        loginOtpRoute,
        signUpFlowRoute,
        locationSearchRoute,
        finalOnboardingRoute,
        personalityFlowRoute,
        profilePicRoute,
        otherGenderRoute,
      ].contains(location);

      if (isLoggedIn) {
        if (location == signInSignUpRoute ||
            location == loginRoute ||
            location == '/' ||
            location.isEmpty) {
          return homeRoute;
        }
        return null;
      }

      if (!isLoggedIn && !isAuthOrOnboarding) {
        return signInSignUpRoute;
      }

      return null;
    },
    routes: appRoutes,
  );

  return _cachedRouter!;
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
