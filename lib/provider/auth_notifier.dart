import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ------------------------------------------------------------------
///  AuthState
/// ------------------------------------------------------------------
class AuthState {
  const AuthState({required this.isLoggedIn, this.token});

  final bool isLoggedIn;
  final String? token;
}

/// ------------------------------------------------------------------
///  AuthNotifier  (AsyncNotifier, Riverpod v2)
/// ------------------------------------------------------------------
class AuthNotifier extends AsyncNotifier<AuthState> {
  // Secure storage (persists token between launches)
  static const _storage = FlutterSecureStorage();

  /// StreamController that lets GoRouter rebuild when auth changes
  final StreamController<void> _streamController =
      StreamController<void>.broadcast();

  Stream<void> get stream => _streamController.stream; // <- used in router

  /// ----------------------------------------------------------------
  /// build() runs once when the provider is first read
  /// ----------------------------------------------------------------
  @override
  FutureOr<AuthState> build() async {
    await _storage.deleteAll(); // 🧨 TEMPORARY LINE
    final token = await _storage.read(key: 'token');
    print('📦 build(): read token = $token');
    return AuthState(isLoggedIn: token != null, token: token);
  }

  /// ----------------------------------------------------------------
  /// Call this from your login flow
  /// ----------------------------------------------------------------
  Future<void> login({required String token}) async {
    await _storage.write(key: 'token', value: token);
    state = AsyncValue.data(AuthState(isLoggedIn: true, token: token));
    print('🔥 login(): isLoggedIn = true');
    _streamController.add(null);
  }

  /// ----------------------------------------------------------------
  /// Call this to log out
  /// ----------------------------------------------------------------
  Future<void> logout() async {
    await _storage.delete(key: 'token');
    state = const AsyncValue.data(AuthState(isLoggedIn: false));
    _streamController.add(null); // notify GoRouter
  }

  /// ----------------------------------------------------------------
  /// Dispose the stream when provider is destroyed
  /// ----------------------------------------------------------------
  @override
  void onDispose() {
    _streamController.close();
  }
}

/// Provider declaration
final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
