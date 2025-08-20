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
  final GlobalKey _tabBarKey = GlobalKey();

  void toggleHighlight() {
    setState(() {
      isHighlightExpanded = !isHighlightExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOwnProfile = widget.viewType == ProfileViewType.own;
    final isCreator = widget.userType == UserType.creator;

    return DefaultTabController(
      length: isCreator ? 3 : 2,
      child: Builder(
        builder: (ctx) {
          final controller = DefaultTabController.of(ctx)!;

          return Scaffold(
            appBar: _buildAppBar(isOwnProfile),
            body: _buildGestureDetector(controller, isCreator),
          );
        },
      ),
    );
  }

  Widget _buildGestureDetector(TabController controller, bool isCreator) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanEnd: (details) {
        // Check if gesture starts below TabBar
        final ctx = _tabBarKey.currentContext;
        if (ctx != null) {
          final box = ctx.findRenderObject() as RenderBox?;
          if (box != null && box.hasSize) {
            final tabTopLeft = box.localToGlobal(Offset.zero);
            final tabBottom = tabTopLeft.dy + box.size.height;

            // Only handle swipes that start below the TabBar
            if (details.globalPosition.dy >= tabBottom) {
              final vx = details.velocity.pixelsPerSecond.dx;
              final vy = details.velocity.pixelsPerSecond.dy;

              // Trigger on horizontal fling (300 px/s threshold)
              if (vx.abs() > vy.abs() && vx.abs() > 300) {
                final next = (controller.index + (vx < 0 ? 1 : -1)).clamp(
                  0,
                  controller.length - 1,
                );
                if (next != controller.index) controller.animateTo(next);
              }
            }
          }
        }
      },
      child: AnimatedBuilder(
        animation: controller.animation!,
        builder: (context, _) {
          return CustomScrollView(
            slivers: [
              if (widget.viewType == ProfileViewType.own)
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildBanner(isCreator),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

              SliverToBoxAdapter(
                child: ProfileHero(
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
                      widget.viewType == ProfileViewType.own
                          ? widget.onToggleProfileType
                          : null,
                  syncContactOption: widget.viewType == ProfileViewType.own,
                  // Action callbacks
                  onEditProfile: widget.onEditProfilePressed,
                  onAddBuddy: widget.onAddBuddyPressed,
                  onFollow: widget.onFollowPressed,
                  onSubscribe: widget.onSubscribePressed,
                  onMessage: widget.onMessagePressed,
                  onShare: widget.onSharePressed,
                  // Relationship info
                  relationship: widget.relationship,
                  isOwnProfile: widget.viewType == ProfileViewType.own,
                ),
              ),

              SliverToBoxAdapter(
                child: ProfileHighlight(
                  isExpanded: isHighlightExpanded,
                  profileType: isCreator ? 'Creator' : 'Explorer',
                  onToggle: toggleHighlight,
                  userName: widget.userData.name,
                  hasHighlightData: widget.userData.hasHighlightData,
                  isOwnProfile: widget.viewType == ProfileViewType.own,
                  highlightImages: widget.userData.highlightImages,
                  highlightNames: widget.userData.highlightNames,
                  profileImage: widget.profileImage ?? widget.userData.imageUrl,
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // TabBar with key
              SliverToBoxAdapter(
                child: Container(
                  key: _tabBarKey,
                  child: PostsTabsBar(
                    profileType: isCreator ? 'Creator' : 'Explorer',
                    userType: widget.userType,
                    viewType: widget.viewType,
                  ),
                ),
              ),

              // Active tab content
              ..._buildPostTabSlivers(
                controller,
                isCreator: isCreator,
                userType: widget.userType,
                viewType: widget.viewType,
              ),
            ],
          );
        },
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

  List<Widget> _buildPostTabSlivers(
    TabController controller, {
    required bool isCreator,
    required UserType? userType,
    required ProfileViewType? viewType,
  }) {
    final index = controller.index;
    final msg = _getEmptyStateMessage(
      userType ?? (isCreator ? UserType.creator : UserType.explorer),
      viewType ?? ProfileViewType.own,
    );

    if (isCreator) {
      switch (index) {
        case 0:
          return QuickiesSlivers();
        case 1:
          return ClipsSlivers();
        case 2:
          return CollectionsSlivers();
        default:
          return [];
      }
    } else {
      switch (index) {
        case 0:
          return UploadsSlivers(
            itemCount: kBuddyUploads.length,
            itemBuilder: (ctx, i) => _buildGridItem(i),
          );
        case 1:
          return TaggedSlivers(message: msg);
        default:
          return [];
      }
    }
  }

  Widget _buildGridItem(int index) {
    return GestureDetector(
      onTap: () {
        // Handle grid item tap
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.asset(kBuddyUploads[index], fit: BoxFit.cover),
        ),
      ),
    );
  }

  String _getEmptyStateMessage(UserType userType, ProfileViewType viewType) {
    if (viewType == ProfileViewType.own) {
      return userType == UserType.creator
          ? 'Your journey starts here—upload your first post and share it with your audience.'
          : 'Your story starts here—upload your first post and share it with friends and family';
    } else {
      return userType == UserType.creator
          ? 'No content available yet.'
          : 'No posts available yet.';
    }
  }
}
