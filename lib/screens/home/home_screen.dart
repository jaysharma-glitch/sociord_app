import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/home/feed_slider.dart';
import 'package:sociord/widgets/home/post_widget.dart';
import 'package:sociord/widgets/home/quicky_recommendation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  int _page = 1;
  bool _isLoadingMore = false;
  bool _alternateRecommendation = false;
  bool _isSheetOpen = false;
  final List<GlobalKey> _postKeys = [];
  // Helper to get or create a stable key for a post index
  GlobalKey _getPostKey(int index) {
    if (_postKeys.length > index) {
      return _postKeys[index];
    } else {
      while (_postKeys.length <= index) {
        _postKeys.add(GlobalKey());
      }
      return _postKeys[index];
    }
  }

  bool showTopRecommendation = true;
  Set<int> dismissedIntervalRecommendations = {};
  List<Widget> _posts = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializePosts();
  }

  void _initializePosts() {
    _posts = _generateInitialPosts();
    _page = 1;
    _isLoadingMore = false;
    _alternateRecommendation = false;
    _postKeys.clear();
  }

  void scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _fetchMorePosts() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _posts.addAll(_generateMorePosts(_page));
      _isLoadingMore = false;
      _page++;
    });
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _initializePosts();
      showTopRecommendation = true;
      dismissedIntervalRecommendations.clear();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore) {
      _fetchMorePosts();
    }
  }

  Widget _buildTopRecommendation() {
    return HomePageRecommendation(
      type: 'Quicky',
      userName: 'Arjun',
      onDismiss: () {
        setState(() {
          showTopRecommendation = false;
        });
      },
      recommendations: const [
        {"image": kQuicky1, "title": "My Royal Transformation"},
        {"image": kQuicky2, "title": "Exploring Cheese"},
        {"image": kQuicky3, "title": "The Modern Man's..."},
      ],
    );
  }

  Widget _buildIntervalRecommendation(int feedIndex) {
    return HomePageRecommendation(
      type: 'Creator',
      userName: 'Arjun',
      onDismiss: () {
        setState(() {
          dismissedIntervalRecommendations.add(feedIndex);
        });
      },
      recommendations: const [
        {"image": kCreator5, "title": "ninapetrov"},
        {"image": kCreator6, "title": "fitandfearless"},
        {"image": kCreator7, "title": "bechamonfield"},
      ],
    );
  }

  bool _shouldShowRecommendation(int page) {
    if (page <= 4) return page % 2 == 0;
    if (page <= 10) return page % 5 == 0;
    if (page <= 20) return page % 10 == 0;
    return false;
  }

  List<Widget> _generateInitialPosts() {
    List<Widget> posts = [
      PostWidget(
        key: _getPostKey(0),
        profileImage: kCreator1,
        postType: 'Quickies',
        username: "darius_nova1",
        category: "Food, Cooking & Beverages",
        postImage: kPost1,
        likes: 120000,
        comments: 500,
        shares: 1000,
        title: "The Ultimate Burger Recipe",
        rating: "Good",
        views: 1200000,
        timeAgo: "30 days ago",
        categoryIconImage: kUtensils,
        categoryColor: const Color(0xFFFA7921).withOpacity(0.5),
        isSubscribed: false,
        onSheetOpen: () {
          _setSheetOpen(true);
          _scrollToPostByKey(_getPostKey(0));
        },
        onSheetClose: () => _setSheetOpen(false),
      ),
      PostWidget(
        key: _getPostKey(1),
        profileImage: kCreator2,
        postType: 'Clips',
        username: "sofia_rivera88",
        category: "Music, Dance & Performance",
        postImage: kPost2,
        likes: 200000,
        comments: 500000,
        shares: 1000,
        title: "Dancing Through Life Freestyle Fun",
        rating: "Excellent",
        views: 250000,
        timeAgo: "10 days ago",
        categoryIconImage: kUtensils,
        categoryColor: const Color(0xFFFA2189).withOpacity(0.5),
        isSubscribed: true,
        onSheetOpen: () {
          _setSheetOpen(true);
          _scrollToPostByKey(_getPostKey(1));
        },
        onSheetClose: () => _setSheetOpen(false),
      ),
    ];
    return posts;
  }

  List<Widget> _generateMorePosts(int page) {
    int startIdx = _postKeys.length;
    List<Widget> morePosts = [];
    if (_shouldShowRecommendation(page) &&
        !dismissedIntervalRecommendations.contains(startIdx)) {
      morePosts.add(_buildIntervalRecommendation(startIdx));
    }
    morePosts.addAll([
      PostWidget(
        key: _getPostKey(startIdx),
        profileImage: kCreator3,
        postType: 'View the Collection',
        username: "hiddeninplainview",
        category: "Art, Design & Creativity",
        postImage: kPost3,
        likes: 2000000,
        comments: 5000000,
        shares: 1000,
        title: "Fragments of Existence",
        rating: "Excellent",
        views: 5000000,
        timeAgo: "25 days ago",
        categoryIconImage: kUtensils,
        categoryColor: const Color(0xFF6621FA).withOpacity(0.5),
        isSubscribed: true,
        onSheetOpen: () {
          _setSheetOpen(true);
          _scrollToPostByKey(_getPostKey(startIdx));
        },
        onSheetClose: () => _setSheetOpen(false),
      ),
      PostWidget(
        key: _getPostKey(startIdx + 1),
        profileImage: kCreator4,
        postType: 'Quickies',
        username: "quietlysneaky",
        category: "Fashion, Beauty & Style",
        postImage: kPost4,
        likes: 45000,
        comments: 500,
        shares: 1000,
        title: "Reimagining the Classic",
        rating: "Nice",
        views: 200000,
        timeAgo: "12 days ago",
        categoryIconImage: kUtensils,
        categoryColor: const Color(0xFF9DD6FF).withOpacity(0.5),
        isSubscribed: false,
        onSheetOpen: () {
          _setSheetOpen(true);
          _scrollToPostByKey(_getPostKey(startIdx + 1));
        },
        onSheetClose: () => _setSheetOpen(false),
      ),
    ]);
    return morePosts;
  }

  void _setSheetOpen(bool open) {
    setState(() {
      _isSheetOpen = open;
    });
  }

  // Scroll to a post by its GlobalKey, retrying if context is not available
  void _scrollToPostByKey(GlobalKey key, [int attempt = 0]) async {
    final context = key.currentContext;
    // Find the index of this key in _postKeys
    final postIndex = _postKeys.indexOf(key);
    // Adjust these values for your UI:
    const double topOffset = 450; // SafeArea + AppBar + FeedSlider
    const double postHeight = 210; // Estimated post height
    if (context != null) {
      await Future.delayed(const Duration(milliseconds: 100));
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: (postIndex == 0 || postIndex == 1) ? 0.0 : 0.1,
      );
    } else if (attempt < 5) {
      await Future.delayed(const Duration(milliseconds: 100));
      _scrollToPostByKey(key, attempt + 1);
    } else if (postIndex == 0) {
      // As a last resort, scroll to offset topOffset for the very first post
      _scrollController.animateTo(
        topOffset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } else if (postIndex == 1) {
      // As a last resort, scroll to offset topOffset + postHeight for the second post
      _scrollController.animateTo(
        topOffset + postHeight,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build feedWidgets and keep a mapping from post key to its index in feedWidgets
    List<Widget> feedWidgets = [
      SizedBox(height: showTopRecommendation ? 55 : 20),
      const FeedSlider(),
    ];
    if (showTopRecommendation) {
      feedWidgets.add(_buildTopRecommendation());
    }
    // We'll build posts with a callback that will be set after feedWidgets is built
    List<Widget> postsWithScroll = [];
    Map<GlobalKey, int> postKeyToFeedIndex = {};
    int feedIndex = feedWidgets.length;
    for (var post in _posts) {
      if (post is PostWidget) {
        postKeyToFeedIndex[post.key as GlobalKey] = feedIndex;
      }
      postsWithScroll.add(post);
      feedIndex++;
    }
    // Filter out dismissed interval recommendations
    feedWidgets.addAll(
      postsWithScroll.where((w) {
        if (w is HomePageRecommendation && w.type == 'Creator') {
          int idx = postsWithScroll.indexOf(w);
          return !dismissedIntervalRecommendations.contains(idx);
        }
        return true;
      }),
    );

    // No need to update onSheetOpen here; handled in _generateInitialPosts/_generateMorePosts

    return SafeArea(
      child: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: feedWidgets.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < feedWidgets.length) {
                  return feedWidgets[index];
                } else {
                  // Loading indicator at the end
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          ),
          // Restore custom AppBar overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedSlide(
              offset: _isSheetOpen ? const Offset(0, -2) : Offset.zero,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: SafeArea(
                bottom: false,
                child: Container(
                  height: kToolbarHeight,
                  color: kAppWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(kLogoText, height: 28),
                      const SizedBox(width: 5),
                      Image.asset(kChevronDown),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {},
                        child: Image.asset(kNotification),
                      ),
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: () {},
                        child: Image.asset(kMessage),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
