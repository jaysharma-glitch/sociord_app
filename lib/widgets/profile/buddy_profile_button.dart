import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/models/buddy_state.dart';
import 'package:sociord/provider/buddy_state_provider.dart';
import 'package:sociord/constants/color.dart';

class BuddyProfileButton extends ConsumerWidget {
  final String userId;
  final String userName;

  const BuddyProfileButton({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buddyState = ref.watch(buddyStateProvider);
    final state = buddyState[userId] ?? BuddyState.notConnected;

    switch (state) {
      case BuddyState.notConnected:
        return _buildAddBuddyButton(context, ref);
      case BuddyState.requestSent:
        return _buildRequestSentButton(context, ref);
      case BuddyState.buddies:
        return _buildBuddiesButton(context, ref);
    }
  }

  Widget _buildAddBuddyButton(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        ElevatedButton(
          onPressed:
              () => ref.read(buddyStateProvider.notifier).sendRequest(userId),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            backgroundColor: kAppPurple,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Add as a buddy',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: 5),
        ElevatedButton(
          onPressed: () {
            // Handle send message
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            backgroundColor: kAppPurple,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Send a Message',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestSentButton(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        ElevatedButton(
          onPressed:
              () => ref
                  .read(buddyStateProvider.notifier)
                  .acceptRequest(userId), // Test: Accept request
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            backgroundColor: kAppOrange,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Request Sent',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: 5),
        ElevatedButton(
          onPressed: () {
            // Handle send message
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            backgroundColor: kAppPurple,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Message',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBuddiesButton(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => _showBuddiesBottomSheet(context, ref),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            backgroundColor: Colors.grey[600],
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Buddies',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 0),
              Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 15),
            ],
          ),
        ),
        const SizedBox(width: 5),
        ElevatedButton(
          onPressed: () {
            // Handle send message
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            backgroundColor: kAppPurple,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Send a Message',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  void _showBuddiesBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 2,
                  decoration: BoxDecoration(
                    color: kAppBlack,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                // Remove buddy option
                ListTile(
                  leading: Icon(Icons.close, color: kAppRed, size: 15),
                  title: Text(
                    'Remove $userName from Buddies',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                  onTap: () {
                    ref.read(buddyStateProvider.notifier).removeBuddy(userId);
                    Navigator.pop(context);
                  },
                ),
                // Block user option
                ListTile(
                  leading: const Icon(Icons.block, color: kAppRed, size: 15),
                  title: Text(
                    'Block $userName',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                  onTap: () {
                    ref.read(buddyStateProvider.notifier).blockUser(userId);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 0),
              ],
            ),
          ),
    );
  }
}
