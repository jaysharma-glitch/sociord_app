import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:sociord/provider/auth_notifier.dart';
import 'package:sociord/provider/onboarding_provider.dart';
import 'package:sociord/utils/routes.dart';

final goRouterProvider = Provider<GoRouter?>((ref) {
  final onboardingDone = ref.watch(onboardingProvider);
  final authState = ref.watch(authProvider);

  if (authState.isLoading || !authState.hasValue)
    return null; // 🧠 Delay router

  final isLoggedIn = authState.value!.isLoggedIn;

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: signInSignUpRoute,
    debugLogDiagnostics: true,
    refreshListenable:
        GoRouterRefreshStream(ref.watch(authProvider.notifier).stream),
    redirect: (_, state) {
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
      ].contains(state.matchedLocation);

      if (!isLoggedIn && !isAuthOrOnboarding) {
        return signInSignUpRoute;
      }

      if (isLoggedIn &&
          !onboardingDone &&
          state.matchedLocation != signUpFlowRoute) {
        return signUpFlowRoute;
      }

      return null;
    },
    routes: appRoutes,
  );
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
