import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/models/buddy_state.dart';

class BuddyStateNotifier extends StateNotifier<Map<String, BuddyState>> {
  BuddyStateNotifier() : super({});

  BuddyState getBuddyState(String userId) {
    return state[userId] ?? BuddyState.notConnected;
  }

  void sendRequest(String userId) {
    state = {...state, userId: BuddyState.requestSent};
  }

  void acceptRequest(String userId) {
    state = {...state, userId: BuddyState.buddies};
  }

  void removeBuddy(String userId) {
    state = {...state, userId: BuddyState.notConnected};
  }

  void blockUser(String userId) {
    state = {...state, userId: BuddyState.notConnected};
  }
}

final buddyStateProvider =
    StateNotifierProvider<BuddyStateNotifier, Map<String, BuddyState>>(
      (ref) => BuddyStateNotifier(),
    );
