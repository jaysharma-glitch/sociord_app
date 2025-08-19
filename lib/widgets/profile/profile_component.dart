import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/profile/profile_banner.dart';
import 'package:sociord/widgets/profile/profile_hero.dart';
import 'package:sociord/widgets/profile/profile_highlight.dart';
import 'package:sociord/widgets/profile/profile_posts.dart';

// Import enums from existing components
import 'package:sociord/widgets/profile/profile_hero.dart'
    show RelationshipType;
import 'package:sociord/widgets/profile/profile_posts.dart'
    show UserType, ProfileViewType;

class ProfileData {
  final String imageUrl;
  final String name;
  final String gender;
  final String age;
  final String location;
  final String handle;
  final int buddies;
  final int subscriptions;
  final int following;
  final String? creatorCategory;
  final bool isVerified;
  final bool hasHighlightData;
  final List<String>? highlightImages;
  final List<String>? highlightNames;

  ProfileData({
    required this.imageUrl,
    required this.name,
    required this.gender,
    required this.age,
    required this.location,
    required this.handle,
    required this.buddies,
    required this.subscriptions,
    required this.following,
    this.creatorCategory,
    this.isVerified = false,
    this.hasHighlightData = true,
    this.highlightImages,
    this.highlightNames,
  });
}

class ProfileComponent extends StatefulWidget {
  final UserType userType;
  final ProfileViewType viewType;
  final RelationshipType relationship;
  final ProfileData userData;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onEditProfilePressed;
  final VoidCallback? onAddBuddyPressed;
  final VoidCallback? onFollowPressed;
  final VoidCallback? onSubscribePressed;
  final VoidCallback? onMessagePressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onToggleProfileType;
  final String? profileImage;

  const ProfileComponent({
    super.key,
    required this.userType,
    required this.viewType,
    required this.relationship,
    required this.userData,
    this.onBackPressed,
    this.onSettingsPressed,
    this.onEditProfilePressed,
    this.onAddBuddyPressed,
    this.onFollowPressed,
    this.onSubscribePressed,
    this.onMessagePressed,
    this.onSharePressed,
    this.onToggleProfileType,
    this.profileImage,
  });

  @override
  State<ProfileComponent> createState() => _ProfileComponentState();
}

class _ProfileComponentState extends State<ProfileComponent> {
  bool isHighlightExpanded = true;

  void toggleHighlight() {
    setState(() {
      isHighlightExpanded = !isHighlightExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOwnProfile = widget.viewType == ProfileViewType.own;
    final isCreator = widget.userType == UserType.creator;

    return Scaffold(
      appBar: _buildAppBar(isOwnProfile),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Banner only for own profile
            if (isOwnProfile) _buildBanner(isCreator),
            if (isOwnProfile) const SizedBox(height: 16),
            // Profile Hero
            ProfileHero(
              imageUrl: widget.userData.imageUrl,
              name: widget.userData.name,
              gender: widget.userData.gender,
              age: widget.userData.age,
              location: widget.userData.location,
              buddies: widget.userData.buddies,
              subscriptions: widget.userData.subscriptions,
              following: widget.userData.following,
              handle: widget.userData.handle,
              profileType: isCreator ? 'Creator' : 'Explorer',
              creatorCategory: widget.userData.creatorCategory ?? '',
              switchProfileType:
                  isOwnProfile ? widget.onToggleProfileType : null,
              syncContactOption: isOwnProfile,
              // Action callbacks
              onEditProfile: widget.onEditProfilePressed,
              onAddBuddy: widget.onAddBuddyPressed,
              onFollow: widget.onFollowPressed,
              onSubscribe: widget.onSubscribePressed,
              onMessage: widget.onMessagePressed,
              onShare: widget.onSharePressed,
              // Relationship info
              relationship: widget.relationship,
              isOwnProfile: isOwnProfile,
            ),
            // Highlights/Showcase section
            ProfileHighlight(
              isExpanded: isHighlightExpanded,
              profileType: isCreator ? 'Creator' : 'Explorer',
              onToggle: toggleHighlight,
              userName: widget.userData.name,
              hasHighlightData: widget.userData.hasHighlightData,
              isOwnProfile: isOwnProfile,
              highlightImages: widget.userData.highlightImages,
              highlightNames: widget.userData.highlightNames,
              profileImage: widget.profileImage ?? widget.userData.imageUrl,
            ),
            const SizedBox(height: 10),
            // Posts section
            ProfilePosts(
              profileType: isCreator ? 'Creator' : 'Explorer',
              userType: widget.userType,
              viewType: widget.viewType,
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isOwnProfile) {
    return AppBar(
      leading:
          isOwnProfile
              ? null
              : IconButton(
                icon: const Icon(Icons.arrow_back, color: kAppBlack),
                onPressed:
                    widget.onBackPressed ?? () => Navigator.of(context).pop(),
              ),
      title: GestureDetector(
        onTap: () {},
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Image.asset(kLogoText, height: 28),
            const SizedBox(width: 5),
            Image.asset(kChevronDown),
          ],
        ),
      ),
      backgroundColor: kAppWhite,
      actions: [
        if (isOwnProfile) ...[
          GestureDetector(
            onTap: widget.onSettingsPressed ?? () {},
            child: Image.asset(kNotification),
          ),
          const SizedBox(width: 15),
          GestureDetector(onTap: () {}, child: Image.asset(kMessage)),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.more_vert, color: kAppBlack),
            onPressed: widget.onSharePressed ?? () {},
          ),
        ],
        const SizedBox(width: 15),
      ],
    );
  }

  Widget _buildBanner(bool isCreator) {
    if (isCreator) {
      return ProfileBanner(
        title: 'Congratulations, ${widget.userData.name}!',
        desc: 'Your Creator Profile is live.',
        image: kChanpagne,
        cta: 'Upload your first post',
        ctaLink: widget.onEditProfilePressed ?? () {},
      );
    } else {
      return ProfileBanner(
        title: 'The Spotlight Awaits',
        desc:
            'Complete a few final details to unlock your creator account and begin earning for your creativity',
        image: kCoins,
        cta: 'Complete now',
        ctaLink: widget.onEditProfilePressed ?? () {},
      );
    }
  }
}
