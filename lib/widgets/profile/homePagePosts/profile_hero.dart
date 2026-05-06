// lib/widgets/profile/profile_hero.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';

import 'package:sociord/widgets/common/profile_picture.dart';
import 'package:sociord/widgets/profile/buddy_profile_button.dart';

enum RelationshipType { none, buddy, following, subscribed }

class ProfileHero extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String gender;
  final String age;
  final String location;
  final bool syncContactOption;
  final int buddies;
  final int subscriptions;
  final int following;
  final String handle;
  final String profileType;
  final String creatorCategory;
  final VoidCallback? switchProfileType;
  // New parameters for unified component
  final VoidCallback? onEditProfile;
  final VoidCallback? onAddBuddy;
  final VoidCallback? onFollow;
  final VoidCallback? onSubscribe;
  final VoidCallback? onMessage;
  final VoidCallback? onShare;
  final RelationshipType? relationship;
  final bool? isOwnProfile;
  /// When set, used for "Creator Dashboard" vs "Become a Creator" button; otherwise profileType is used.
  final bool? isCertifiedCreator;

  const ProfileHero({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.gender,
    required this.age,
    required this.location,
    required this.syncContactOption,
    required this.buddies,
    required this.subscriptions,
    required this.following,
    required this.handle,
    required this.profileType,
    required this.creatorCategory,
    this.switchProfileType,
    // New parameters
    this.onEditProfile,
    this.onAddBuddy,
    this.onFollow,
    this.onSubscribe,
    this.onMessage,
    this.onShare,
    this.relationship,
    this.isOwnProfile,
    this.isCertifiedCreator,
  });

  @override
  Widget build(BuildContext context) {
    final isCreator = profileType == 'Creator';
    final theme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          SizedBox(
            height: 160,

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfilePicture(
                  imageUrl: imageUrl,
                  imageSize: 160,
                  borderRadius: 5,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRect(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          name,
                          style: theme.headlineSmall!.copyWith(
                            color: kAppBlack,
                            height: 1.1,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // User type pill with airplane icon: "Creator" or "Explorer"
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
                              Flexible(
                                child: Text(
                                  isCreator
                                      ? (creatorCategory.isNotEmpty
                                          ? 'Creator · $creatorCategory'
                                          : 'Creator')
                                      : 'Explorer',
                                  style: theme.bodySmall!.copyWith(
                                    color: kAppBlack,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        if ([gender, age]
                            .where((s) => s.toString().trim().isNotEmpty)
                            .isNotEmpty)
                          _infoRow(
                            Icons.person_rounded,
                            [gender, age]
                                .where((s) => s.toString().trim().isNotEmpty)
                                .join(', '),
                          ),
                        if (location.trim().isNotEmpty)
                          _infoRow(Icons.location_pin, location),
                        const SizedBox(height: 5),
                        if (syncContactOption)
                          _syncContactsSection(context, theme),
                        Spacer(),
                        _statsRow(theme),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isCreator ? 10 : 16),
          _handleAndProfileSwitch(context, theme),
          const SizedBox(height: 8),
          _actionButtons(context, theme),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kAppPurple),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _syncContactsSection(BuildContext context, TextTheme theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: kBorderGreay,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Want to see who's on Sociord?",
            style: theme.bodySmall!.copyWith(fontSize: 9),
          ),
          GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Text(
                  "Sync Contacts",
                  style: theme.bodySmall!.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: kAppPurple,
                  ),
                ),
                const SizedBox(width: 2),
                Image.asset(kRightArrow, height: 10, width: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(TextTheme theme) {
    Widget stat(String label, int value) {
      return Column(
        children: [
          Text(
            value.toString(),
            style: theme.headlineSmall!.copyWith(
              fontSize: 15,
              color: kAppBlack,
            ),
          ),
          Text(label, style: theme.bodySmall),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        stat('Buddies', buddies),
        stat('Subscriptions', subscriptions),
        stat('Following', following),
      ],
    );
  }

  Widget _handleAndProfileSwitch(BuildContext context, TextTheme theme) {
    final isCreator = profileType == 'Creator';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              handle,
              style: theme.bodySmall!.copyWith(fontFamily: "Gibson"),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.open_in_new, size: 15, color: kAppPurple),
          ],
        ),
        const SizedBox(height: 4),
        if (isOwnProfile ?? false)
          GestureDetector(
            onTap:
                creatorCategory.isEmpty
                    ? () => context.go("/profile/becomeACreator")
                    : switchProfileType,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isCreator ? 'Creator Profile' : 'Personal Profile',
                  style: theme.bodySmall!.copyWith(
                    fontFamily: "Gibson",
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kAppBlack,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Switch',
                  style: theme.bodySmall!.copyWith(
                    fontFamily: "Gibson",
                    fontSize: 10,
                    decoration: TextDecoration.underline,
                    decorationThickness: 3,
                    color: kAppPurple,
                  ),
                ),
                const SizedBox(width: 2),
                Image.asset(kChevronDown, height: 8),
              ],
            ),
          ),
      ],
    );
  }

  Widget _actionButtons(BuildContext context, TextTheme theme) {
    final isOwn = isOwnProfile ?? true;
    final isCreator = profileType == 'Creator';
    final showCreatorDashboard = isCertifiedCreator ?? isCreator;

    if (isOwn) {
      // Own profile actions - match the original button style
      return Row(
        children: [
          ElevatedButton(
            onPressed: onEditProfile ?? () {},
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              backgroundColor: kAppBlack,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Edit Profile',
              style: theme.headlineSmall!.copyWith(
                fontSize: 13,
                color: kAppWhite,
              ),
            ),
          ),
          const SizedBox(width: 5),
          ElevatedButton(
            onPressed: () {
              if (showCreatorDashboard) {
                // Navigate to creator dashboard or settings
                onEditProfile?.call();
              } else {
                // Navigate to become a creator
                context.go("/profile/becomeACreator");
              }
            },
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              backgroundColor: kAppPurple,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              showCreatorDashboard ? 'Creator Dashboard' : 'Become a Creator',
              style: theme.headlineSmall!.copyWith(
                fontSize: 13,
                color: kAppWhite,
              ),
            ),
          ),
        ],
      );
    } else {
      // Other user's profile actions - use BuddyProfileButton for non-creator profiles
      if (isCreator) {
        // Creator profiles use original logic
        return Row(
          children: [
            ElevatedButton(
              onPressed: _getPrimaryAction(),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                backgroundColor: _getPrimaryButtonColor(),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _getPrimaryButtonText(),
                style: theme.headlineSmall!.copyWith(
                  fontSize: 12,
                  color: kAppWhite,
                ),
              ),
            ),
            const SizedBox(width: 5),
            if (onMessage != null)
              ElevatedButton(
                onPressed: onMessage,
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
                  'Message',
                  style: theme.headlineSmall!.copyWith(
                    fontSize: 12,
                    color: kAppWhite,
                  ),
                ),
              ),
          ],
        );
      } else {
        // Explorer profiles use new BuddyProfileButton
        return BuddyProfileButton(
          userId: handle, // Use handle as userId for now
          userName: name,
        );
      }
    }
  }

  VoidCallback _getPrimaryAction() {
    switch (relationship ?? RelationshipType.none) {
      case RelationshipType.none:
        return isOwnProfile ?? false
            ? (onEditProfile ?? () {})
            : (profileType == 'Creator'
                ? (onSubscribe ?? onFollow ?? () {})
                : (onAddBuddy ?? () {}));
      case RelationshipType.buddy:
        return onMessage ?? () {};
      case RelationshipType.following:
        return onFollow ?? () {};
      case RelationshipType.subscribed:
        return onSubscribe ?? () {};
    }
  }

  Color _getPrimaryButtonColor() {
    switch (relationship ?? RelationshipType.none) {
      case RelationshipType.none:
        return kAppPurple;
      case RelationshipType.buddy:
        return kAppBlack;
      case RelationshipType.following:
        return kAppBlack;
      case RelationshipType.subscribed:
        return kAppBlack;
    }
  }

  String _getPrimaryButtonText() {
    switch (relationship ?? RelationshipType.none) {
      case RelationshipType.none:
        return profileType == 'Creator' ? 'Subscribe' : 'Add Buddy';
      case RelationshipType.buddy:
        return 'Message';
      case RelationshipType.following:
        return 'Following';
      case RelationshipType.subscribed:
        return 'Subscribed';
    }
  }
}
