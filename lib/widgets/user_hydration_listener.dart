import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/provider/auth_notifier.dart';
import 'package:sociord/provider/user_provider.dart';

/// When mounted and user has token but no profile data, hydrates user from API.
/// Place once in the app (e.g. in the shell) so profile data is loaded when user lands on home.
class UserHydrationListener extends ConsumerStatefulWidget {
  final Widget child;

  const UserHydrationListener({super.key, required this.child});

  @override
  ConsumerState<UserHydrationListener> createState() => _UserHydrationListenerState();
}

class _UserHydrationListenerState extends ConsumerState<UserHydrationListener> {
  bool _attempted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrate());
  }

  Future<void> _hydrate() async {
    if (_attempted) return;
    final authState = ref.read(authProvider);
    if (authState.isLoading || !authState.hasValue) return;
    final token = authState.value?.token;
    if (token == null || token.isEmpty) return;
    final user = ref.read(userNotifierProvider);
    if (user.firstName != null && user.firstName!.isNotEmpty) return;
    _attempted = true;
    final notifier = ref.read(userNotifierProvider.notifier);
    if (user.userId == null || user.userId!.isEmpty) {
      notifier.setUserId(token);
    }
    try {
      await notifier.getUser();
    } catch (_) {
      // getUser no longer throws; catch any unexpected error
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
