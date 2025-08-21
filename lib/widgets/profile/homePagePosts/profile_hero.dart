// lib/widgets/profile/profile_hero.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/utils/routes.dart';
import 'package:sociord/widgets/common/profile_picture.dart';

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        name,
                        style: theme.headlineSmall!.copyWith(color: kAppBlack),
                      ),
                      const SizedBox(height: 4),
                      if (isCreator && creatorCategory.isNotEmpty)
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
                                creatorCategory,
                                style: theme.bodySmall!.copyWith(
                                  color: kAppBlack,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 2),
                      _infoRow(Icons.person_rounded, '$gender, $age'),
                      _infoRow(Icons.location_pin, location),
                      const SizedBox(height: 5),
                      if (syncContactOption)
                        _syncContactsSection(context, theme),
                      Spacer(),
                      _statsRow(theme),
                    ],
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
        Text(text, style: const TextStyle(fontSize: 12)),
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
    return Row(
      children: [
        Text(handle, style: theme.bodySmall!.copyWith(fontFamily: "Gibson")),
        const SizedBox(width: 10),
        const Icon(Icons.open_in_new, size: 15, color: kAppPurple),
        const Spacer(),
        if (isOwnProfile ?? false)
          GestureDetector(
            onTap:
                creatorCategory.isEmpty
                    ? () => context.go("/profile/becomeACreator")
                    : switchProfileType,
            child: Row(
              children: [
                Text(
                  'Switch',
                  style: theme.bodySmall!.copyWith(
                    fontFamily: "Gibson",
                    fontSize: 10,
                    decoration: TextDecoration.underline,
                    decorationThickness: 3,
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
    final currentRelationship = relationship ?? RelationshipType.none;
    final isCreator = profileType == 'Creator';

    if (isOwn) {
      // Own profile actions
      return Row(
        children: [
          ElevatedButton(
            onPressed: onEditProfile ?? () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              backgroundColor: kAppBlack,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Edit Profile',
              style: theme.headlineSmall!.copyWith(
                fontSize: 12,
                color: kAppWhite,
              ),
            ),
          ),
          const SizedBox(width: 5),
          ElevatedButton(
            onPressed: onEditProfile,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              backgroundColor: kAppPurple,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              isCreator ? 'View Creator Dashboard' : 'Become a Creator',
              style: theme.headlineSmall!.copyWith(
                fontSize: 12,
                color: kAppWhite,
              ),
            ),
          ),
        ],
      );
    } else {
      // Other user's profile actions
      return Row(
        children: [
          // Primary action button
          ElevatedButton(
            onPressed: _getPrimaryAction(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          // Secondary action button
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
