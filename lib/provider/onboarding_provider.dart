import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod provider: `false` until user finishes onboarding
final onboardingProvider =
    NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);

class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() => false; // default: not finished

  /// Call this exactly once when onboarding is done
  void setDone(bool value) => state = value; // ✅ single, consistent name
}
