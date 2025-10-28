import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/widgets/common/profile_picture.dart';
import 'package:sociord/widgets/gradient_text.dart';
import 'package:sociord/widgets/profile/creator_follow_bottom_sheet.dart';
import 'package:sociord/widgets/profile/creator_subscribe_bottom_sheet.dart';
import 'package:sociord/widgets/profile/creator_subscription_management_bottom_sheet.dart';

// State management for creator interactions
class CreatorInteractionNotifier
    extends StateNotifier<Map<String, CreatorInteractionState>> {
  CreatorInteractionNotifier() : super({});

  CreatorInteractionState getCreatorState(String creatorId) {
    return state[creatorId] ?? CreatorInteractionState();
  }

  void toggleFollow(String creatorId) {
    final currentState = getCreatorState(creatorId);
    state = {
      ...state,
      creatorId: currentState.copyWith(isFollowing: !currentState.isFollowing),
    };
  }

  void toggleSubscribe(String creatorId) {
    final currentState = getCreatorState(creatorId);
    state = {
      ...state,
      creatorId: currentState.copyWith(
        isSubscribed: !currentState.isSubscribed,
      ),
    };
  }
}

class CreatorInteractionState {
  final bool isFollowing;
  final bool isSubscribed;

  CreatorInteractionState({
    this.isFollowing = false,
    this.isSubscribed = false,
  });

  CreatorInteractionState copyWith({bool? isFollowing, bool? isSubscribed}) {
    return CreatorInteractionState(
      isFollowing: isFollowing ?? this.isFollowing,
      isSubscribed: isSubscribed ?? this.isSubscribed,
    );
  }
}

final creatorInteractionProvider = StateNotifierProvider<
  CreatorInteractionNotifier,
  Map<String, CreatorInteractionState>
>((ref) => CreatorInteractionNotifier());

class CreatorProfileHero extends ConsumerWidget {
  final String name;
  final String gender;
  final String age;
  final String location;
  final String handle;
  final int subscribers;
  final int followers;
  final double rating;
  final String? creatorCategory;
  final String profileImage;
  final VoidCallback? onFollowPressed;
  final VoidCallback? onSubscribePressed;
  final VoidCallback? onMessagePressed;

  const CreatorProfileHero({
    super.key,
    required this.name,
    required this.gender,
    required this.age,
    required this.location,
    required this.handle,
    required this.subscribers,
    required this.followers,
    required this.rating,
    this.creatorCategory,
    required this.profileImage,
    this.onFollowPressed,
    this.onSubscribePressed,
    this.onMessagePressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creatorId = handle; // Use handle as creator ID
    final interactionState =
        ref.watch(creatorInteractionProvider)[creatorId] ??
        CreatorInteractionState();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile picture
                ProfilePicture(
                  imageUrl: profileImage,
                  imageSize: 120,
                  borderRadius: 5,
                ),
                const SizedBox(width: 10),

                // Profile details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      // Name
                      Text(
                        name,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall!.copyWith(color: kAppBlack),
                      ),
                      const SizedBox(height: 4),

                      // Category badge
                      if (creatorCategory != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: kAppYellow,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.airplanemode_active,
                                size: 12,
                                color: kAppBlack,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                creatorCategory!,
                                style: Theme.of(context).textTheme.bodySmall!
                                    .copyWith(color: kAppBlack),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],

                      // Demographics
                      _infoRow(Icons.person_rounded, '$gender, $age'),
                      _infoRow(Icons.location_pin, location),
                      const SizedBox(height: 5),

                      Spacer(),

                      // Stats row
                      _statsRow(Theme.of(context).textTheme),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // Handle
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                handle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall!.copyWith(color: kAppBlack),
              ),
              const SizedBox(width: 4),
              Icon(Icons.open_in_new, size: 14, color: kAppPurple),
            ],
          ),

          const SizedBox(height: 8),

          // Action buttons
          Row(
            children: [
              // Follow button
              ElevatedButton(
                onPressed: () {
                  if (interactionState.isFollowing) {
                    // Show bottom sheet for unfollow/block options
                    _showFollowOptionsBottomSheet(context, ref, creatorId);
                  } else {
                    // Follow the creator
                    ref
                        .read(creatorInteractionProvider.notifier)
                        .toggleFollow(creatorId);
                    onFollowPressed?.call();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  backgroundColor:
                      interactionState.isFollowing ? kAppBlack : kAppPurple,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  interactionState.isFollowing ? 'Following' : 'Follow',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontSize: 12,
                    color: kAppWhite,
                  ),
                ),
              ),
              const SizedBox(width: 5),

              // Subscribe button
              ElevatedButton(
                onPressed: () {
                  _showSubscribeOptionsBottomSheet(context, ref, creatorId);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 3,
                  ),
                  backgroundColor:
                      interactionState.isSubscribed ? kAppBlack : kAppPurple,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    Text(
                      interactionState.isSubscribed
                          ? 'Subscribed'
                          : 'Subscribe',
                      style: Theme.of(context).textTheme.headlineSmall!
                          .copyWith(fontSize: 12, color: kAppWhite),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: kAppWhite,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),

              // Send Message button
              ElevatedButton(
                onPressed: onMessagePressed,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  backgroundColor: kAppPurple,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Send a Message',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontSize: 12,
                    color: kAppWhite,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Bio placeholder
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: kAppBlack,
              ),
              children: [
                const TextSpan(
                  text:
                      'Lorem ipsum dolor sit amet, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum... ',
                ),
                TextSpan(
                  text: 'Read More',
                  style: TextStyle(
                    color: kAppPurple,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Widget _infoRow(IconData icon, String text) {
    return Builder(
      builder:
          (context) => Row(
            children: [
              Icon(icon, size: 18, color: kAppPurple),
              const SizedBox(width: 4),
              Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall!.copyWith(color: kAppBlack),
              ),
            ],
          ),
    );
  }

  Widget _statsRow(TextTheme theme) {
    Widget stat(String label, dynamic value) {
      return Column(
        children: [
          Text(
            value.toString(),
            style: theme.headlineSmall!.copyWith(
              color: kAppBlack,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Text(
            label,
            style: theme.bodySmall!.copyWith(
              color: kAppBlack,
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        stat('Subscribers', _formatNumber(subscribers)),
        stat('Followers', _formatNumber(followers)),
        stat('Rating', rating),
      ],
    );
  }

  void _showFollowOptionsBottomSheet(
    BuildContext context,
    WidgetRef ref,
    String creatorId,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CreatorFollowBottomSheet(
            creatorName: name,
            onUnfollow: () {
              ref
                  .read(creatorInteractionProvider.notifier)
                  .toggleFollow(creatorId);
              onFollowPressed?.call();
            },
            onBlock: () {
              // Handle block action
              print('Block $name');
              // You can add block logic here
            },
          ),
    );
  }

  void _showSubscribeOptionsBottomSheet(
    BuildContext context,
    WidgetRef ref,
    String creatorId,
  ) {
    // Check if user is already subscribed to show appropriate bottom sheet
    final interactionState =
        ref.read(creatorInteractionProvider)[creatorId] ??
        CreatorInteractionState();

    if (interactionState.isSubscribed) {
      // Show subscription management bottom sheet for existing subscribers
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder:
            (context) => CreatorSubscriptionManagementBottomSheet(
              creatorName: name,
              onViewPackages: () {
                print('View packages for $name');
                // Handle view packages action
              },
              onCancelSubscription: () {
                ref
                    .read(creatorInteractionProvider.notifier)
                    .toggleSubscribe(creatorId);
                onSubscribePressed?.call();
                print('Cancel subscription to $name');
              },
              onEditSubscription: () {
                print('Edit subscription for $name');
                // Handle edit subscription action
              },
              onAskCreator: () {
                print('Ask $name');
                // Handle ask creator action
              },
              onContactSupport: () {
                print('Contact support');
                // Handle contact support action
              },
            ),
      );
    } else {
      // Show subscription options bottom sheet for new subscribers
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder:
            (context) => CreatorSubscribeBottomSheet(
              creatorName: name,
              onViewPackages: () {
                print('View packages for $name');
                // Handle view packages action
              },
              onSubscribeMonthly: () {
                ref
                    .read(creatorInteractionProvider.notifier)
                    .toggleSubscribe(creatorId);
                onSubscribePressed?.call();
                print('Subscribe monthly to $name');
              },
              onSubscribeYearly: () {
                ref
                    .read(creatorInteractionProvider.notifier)
                    .toggleSubscribe(creatorId);
                onSubscribePressed?.call();
                print('Subscribe yearly to $name');
              },
              onAskCreator: () {
                print('Ask $name');
                // Handle ask creator action
              },
              onContactSupport: () {
                print('Contact support');
                // Handle contact support action
              },
            ),
      );
    }
  }
}
