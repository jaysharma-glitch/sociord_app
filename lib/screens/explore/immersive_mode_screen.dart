import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/constants/text_styles.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/home/comments_bottom_sheet.dart';
import 'package:sociord/widgets/home/ratings_bottom_sheet.dart';
import 'package:sociord/widgets/home/share_bottom_sheet.dart';
import 'package:sociord/widgets/common/options_bottom_sheet.dart';

class ImmersiveModeScreen extends StatefulWidget {
  final int initialIndex;
  final List<ImmersivePost> posts;

  const ImmersiveModeScreen({
    super.key,
    required this.initialIndex,
    required this.posts,
  });

  @override
  State<ImmersiveModeScreen> createState() => _ImmersiveModeScreenState();
}

class _ImmersiveModeScreenState extends State<ImmersiveModeScreen> {
  late PageController _pageController;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with white background
          _buildHeader(),

          // Search suggestions (only show when search is visible)
          if (_isSearchVisible) _buildSearchSuggestions(),

          // Main content with PageView for vertical scrolling
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                // Page changed - could be used for analytics or other purposes
              },
              itemCount: widget.posts.length,
              itemBuilder: (context, index) {
                return _buildPostView(widget.posts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostView(ImmersivePost post) {
    return Column(
      children: [
        // Image section - takes up about 60-70% of screen
        Expanded(
          flex: 20,
          child: Stack(
            children: [
              // Main image/video
              Positioned.fill(
                child: Image.asset(
                  post.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, color: Colors.white),
                    );
                  },
                ),
              ),

              // Category badges overlay
              Positioned(
                top: 20,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Art, Design & Creativity badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: kAppPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Art, Design & Creativity',
                            style: kBodySmallWhite.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Quickies badge
              Positioned(
                top: 20,
                right: 60, // Moved left to make room for 3 dots menu
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Quickies',
                    style: kBodySmallWhite.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              // Three dots menu
              Positioned(
                top: 20,
                right: 16,
                child: GestureDetector(
                  onTap: () => _openOptionsSheet(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.white, Colors.white],
                    ),
                  ),
                  child: Row(
                    children: [
                      // Profile picture
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage(
                              post.imageUrl,
                            ), // Using same image as placeholder
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        post.username,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: kBorderGreay),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          'Follow',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall!.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: kBorderGreay),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          'Subscribe',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall!.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content section with white background
        Expanded(flex: 3, child: _buildBottomContent(post)),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: kToolbarHeight + 50,
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 40),
      child: _isSearchVisible ? _buildSearchHeader() : _buildNormalHeader(),
    );
  }

  Widget _buildNormalHeader() {
    return Row(
      children: [
        // Sociord logo with dropdown
        Row(
          children: [
            Image.asset(kLogoText, height: 28),
            const SizedBox(width: 5),
            Image.asset(kChevronDown),
          ],
        ),
        const Spacer(),
        // Search and close icons
        GestureDetector(
          onTap: () {
            setState(() {
              _isSearchVisible = true;
            });
            // Focus the search field after the widget rebuilds
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _searchFocusNode.requestFocus();
            });
          },
          child: const Icon(Icons.search, color: Colors.black, size: 24),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(Icons.close, color: Colors.black, size: 24),
        ),
      ],
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          // Search icon
          const Icon(Icons.search, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          // Search input field
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: const InputDecoration(
                hintText: 'What would you like to see ?',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              style: const TextStyle(color: Colors.black, fontSize: 16),
              onSubmitted: (value) {
                // TODO: Handle search
                print('Searching for: $value');
              },
            ),
          ),
          // Close button
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearchVisible = false;
                _searchController.clear();
              });
              _searchFocusNode.unfocus();
            },
            child: const Icon(Icons.close, color: Colors.black, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final searchSuggestions = [
      'Chicken Pot Pie',
      'How to jive',
      'How to build muscle',
      'Date Ideas',
      'Style Snapshots',
      'Weekend Wonders',
      'The Snack Attack',
      'Behind the Lens',
      'Chill Beats, Hot Vibes',
      'Snack-Sized Stories',
    ];

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: searchSuggestions.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                _searchController.text = searchSuggestions[index];
                // TODO: Handle search suggestion tap
                print('Searching for: ${searchSuggestions[index]}');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  searchSuggestions[index],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomContent(ImmersivePost post) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Engagement metrics - matching home page post style
          Row(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _openRatingsSheet(context),
                    child: const Icon(
                      Icons.star_rounded,
                      color: kAppPurple,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${post.likes}",
                    style: _bodyText(context, weight: FontWeight.w400),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _openCommentsSheet(context),
                    child: const Icon(
                      Icons.chat_bubble,
                      color: Colors.black54,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${post.comments}",
                    style: _bodyText(context, weight: FontWeight.w400),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _openShareSheet(context),
                    child: const Icon(
                      Icons.share,
                      color: Colors.black54,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Post title and metadata - matching home page post style
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
            child: Text(
              post.title,
              style: _headlineText(context, color: kAppBlack, size: 15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Text(
              "Rated Excellent | ${post.views} Views | ${post.timeAgo}",
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // Helper methods matching home page post widget
  TextStyle _headlineText(
    BuildContext context, {
    double size = 14,
    Color color = kAppBlack,
  }) {
    return Theme.of(
      context,
    ).textTheme.headlineSmall!.copyWith(fontSize: size, color: color);
  }

  TextStyle _bodyText(
    BuildContext context, {
    FontWeight weight = FontWeight.w400,
  }) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: weight);
  }

  // Action sheet methods matching home page post widget
  void _openCommentsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CommentsBottomSheet(),
    );
  }

  void _openRatingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const RatingsBottomSheet(),
    );
  }

  void _openShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ShareBottomSheet(),
    );
  }

  void _openOptionsSheet(BuildContext context) {
    OptionsBottomSheet.show(
      context: context,
      type: BottomSheetType.exploreImmersivePost,
    );
  }
}

// Model for immersive posts
class ImmersivePost {
  final String id;
  final String imageUrl;
  final String username;
  final String title;
  final int likes;
  final int comments;
  final int views;
  final String timeAgo;

  ImmersivePost({
    required this.id,
    required this.imageUrl,
    required this.username,
    required this.title,
    required this.likes,
    required this.comments,
    required this.views,
    required this.timeAgo,
  });
}
