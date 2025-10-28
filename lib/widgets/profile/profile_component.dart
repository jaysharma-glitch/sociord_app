import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/profile/homePagePosts/profile_banner.dart';
import 'package:sociord/widgets/profile/homePagePosts/profile_hero.dart';
import 'package:sociord/widgets/profile/homePagePosts/creator_profile_hero.dart';
import 'package:sociord/widgets/profile/homePagePosts/profile_highlight.dart';
import 'package:sociord/widgets/profile/profile_posts.dart';
import 'package:sociord/widgets/profile/buddyProfilePost/post_reader_page.dart';
import 'package:sociord/widgets/profile/buddyProfilePost/post_source.dart';
import 'package:sociord/widgets/profile/buddyProfilePost/mock_post_repo.dart';
import 'package:sociord/widgets/profile/buddyProfilePost/grid_post_tile.dart';
import 'package:sociord/widgets/common/options_bottom_sheet.dart';

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
  final int? subscribers;
  final int? followers;
  final double? rating;
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
    this.subscribers,
    this.followers,
    this.rating,
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
  bool _isLandscapeMode = false; // State for clips orientation
  bool _isCollectionsHorizontal = true; // State for collections orientation
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
          final controller = DefaultTabController.of(ctx);

          return Scaffold(
            appBar: _buildAppBar(isOwnProfile),
            body: _buildGestureDetector(controller, isCreator),
          );
        },
      ),
    );
  }

  void _openSociordOptions(BuildContext context, bool isOwnProfile) {
    if (isOwnProfile) {
      // For own profile, we need to determine if it's personal or creator
      final isCreator = widget.userType == UserType.creator;
      OptionsBottomSheet.show(
        context: context,
        type:
            isCreator
                ? BottomSheetType.selfProfileCreator
                : BottomSheetType.selfProfilePersonal,
      );
    } else {
      // For other person's profile
      final isCreator = widget.userType == UserType.creator;
      OptionsBottomSheet.show(
        context: context,
        type: BottomSheetType.profileOptions,
        isCreator: isCreator,
      );
    }
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
            physics: const ClampingScrollPhysics(),
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
                child:
                    isCreator
                        ? CreatorProfileHero(
                          name: widget.userData.name,
                          gender: widget.userData.gender,
                          age: widget.userData.age,
                          location: widget.userData.location,
                          handle: widget.userData.handle,
                          subscribers: widget.userData.subscribers ?? 0,
                          followers: widget.userData.followers ?? 0,
                          rating: widget.userData.rating ?? 0.0,
                          creatorCategory: widget.userData.creatorCategory,
                          profileImage: widget.userData.imageUrl,
                          onFollowPressed: widget.onFollowPressed,
                          onSubscribePressed: widget.onSubscribePressed,
                          onMessagePressed: widget.onMessagePressed,
                        )
                        : ProfileHero(
                          imageUrl: widget.userData.imageUrl,
                          name: widget.userData.name,
                          gender: widget.userData.gender,
                          age: widget.userData.age,
                          location: widget.userData.location,
                          buddies: widget.userData.buddies,
                          subscriptions: widget.userData.subscriptions,
                          following: widget.userData.following,
                          handle: widget.userData.handle,
                          profileType: isCreator ? 'Creator' : 'Personal',
                          creatorCategory:
                              widget.userData.creatorCategory ?? '',
                          switchProfileType:
                              widget.viewType == ProfileViewType.own
                                  ? widget.onToggleProfileType
                                  : null,
                          syncContactOption:
                              widget.viewType == ProfileViewType.own,
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
        onTap: () => _openSociordOptions(context, isOwnProfile),
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
          return QuickiesSlivers(
            itemCount: 9, // Creator quickies have 9 images (1-9)
            itemBuilder: (ctx, i) => _buildCreatorQuickieItem(ctx, i),
          );
        case 1:
          return ClipsSlivers(
            isLandscapeMode: _isLandscapeMode,
            onOrientationChanged: (isLandscape) {
              setState(() {
                _isLandscapeMode = isLandscape;
              });
            },
          );
        case 2:
          return CollectionsSlivers(
            isHorizontalMode: _isCollectionsHorizontal,
            onOrientationChanged: (isHorizontal) {
              setState(() {
                _isCollectionsHorizontal = isHorizontal;
              });
            },
          );
        default:
          return [];
      }
    } else {
      switch (index) {
        case 0:
          return UploadsSlivers(
            itemCount: MockPostRepo.allPosts.length, // Use actual post count
            itemBuilder: (ctx, i) => _buildGridItem(ctx, i),
          );
        case 1:
          return TaggedSlivers(message: msg);
        default:
          return [];
      }
    }
  }

  Widget _buildGridItem(BuildContext context, int index) {
    // Get the actual post from mock data
    final posts = MockPostRepo.allPosts;
    if (index >= posts.length) {
      return Container(); // Return empty container if index out of bounds
    }

    final post = posts[index];

    return Container(
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
        child: GridPostTile(
          post: post,
          onTap: () {
            // Navigate to PostReaderPage
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (_) => PostReaderPage(
                      userId: 'user_1', // Replace with actual user ID
                      initialPostId: post.id, // Use actual post ID
                      source:
                          PostSource.uploads, // or tagged based on current tab
                      userName: widget.userData.name,
                      profileImage: widget.userData.imageUrl,
                      isCreator: widget.userType == UserType.creator,
                    ),
                fullscreenDialog: true, // feels like a sheet
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCreatorQuickieItem(BuildContext context, int index) {
    if (index >= kCreatorQuickies.length) {
      return Container();
    }

    final imagePath = kCreatorQuickies[index];

    return Container(
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
        child: GestureDetector(
          onTap: () {
            // Navigate to PostReaderPage for creator content
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (_) => PostReaderPage(
                      userId: 'creator_1', // Replace with actual creator ID
                      initialPostId: 'creator_post_$index',
                      source: PostSource.uploads,
                      userName: widget.userData.name,
                      profileImage: widget.userData.imageUrl,
                      isCreator: widget.userType == UserType.creator,
                    ),
                fullscreenDialog: true,
              ),
            );
          },
          child: Image.asset(imagePath, fit: BoxFit.cover),
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
