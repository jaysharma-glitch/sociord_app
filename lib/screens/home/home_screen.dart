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
  final List<Widget> _feed = [];
  int _page = 1;
  bool _isLoadingMore = false;
  bool _alternateRecommendation = false;
  bool _isSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _initializeFeed();
    _scrollController.addListener(_onScroll);
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

  void _initializeFeed() {
    _feed.addAll([
      const FeedSlider(),
      _buildRecommendation('Quicky'),
      ..._generatePostWidgets(),
    ]);
  }

  Future<void> _fetchMorePosts() async {
    if (_isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _feed.addAll(_generatePostWidgets());
      _isLoadingMore = false;
      _page++;
    });
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _feed.clear();
      _page = 1;
      _initializeFeed();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore) {
      _fetchMorePosts();
    }
  }

  Widget _buildRecommendation(String type) {
    return HomePageRecommendation(
      type: type,
      userName: 'Arjun',
      onDismiss: () {},
      recommendations:
          type == 'Quicky'
              ? const [
                {"image": kQuicky1, "title": "My Royal Transformation"},
                {"image": kQuicky2, "title": "Exploring Cheese"},
                {"image": kQuicky3, "title": "The Modern Man's..."},
              ]
              : const [
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

  List<Widget> _generatePostWidgets() {
    List<Widget> posts = [
      PostWidget(
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
          scrollPostIntoView(0);
        },
        onSheetClose: () => _setSheetOpen(false),
      ),
      PostWidget(
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
          scrollPostIntoView(1);
        },
        onSheetClose: () => _setSheetOpen(false),
      ),
      PostWidget(
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
          scrollPostIntoView(2);
        },
        onSheetClose: () => _setSheetOpen(false),
      ),
      PostWidget(
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
          scrollPostIntoView(3);
        },
        onSheetClose: () => _setSheetOpen(false),
      ),
    ];

    if (_shouldShowRecommendation(_page)) {
      posts.insert(
        2,
        _buildRecommendation(_alternateRecommendation ? 'Quicky' : 'Creator'),
      );
      _alternateRecommendation = !_alternateRecommendation;
    }

    return posts;
  }

  void _setSheetOpen(bool open) {
    setState(() {
      _isSheetOpen = open;
    });
  }

  void scrollPostIntoView(int postIndex) {
    // Calculate offset for the post (profile/meta at top)
    // For simplicity, assume each post has a fixed height (or use a GlobalKey for more accuracy)
    double offset = 0;
    for (int i = 0; i < postIndex; i++) {
      offset += 400; // Approximate post height, adjust as needed
    }
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedSlide(
          offset: _isSheetOpen ? const Offset(0, -1) : Offset.zero,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: AppBar(
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(kLogoText, height: 28),
                const SizedBox(width: 5),
                Image.asset(kChevronDown),
              ],
            ),
            backgroundColor: kAppWhite,
            actions: [
              GestureDetector(onTap: () {}, child: Image.asset(kNotification)),
              const SizedBox(width: 15),
              GestureDetector(onTap: () {}, child: Image.asset(kMessage)),
              const SizedBox(width: 15),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _feed.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _feed.length) {
              final widget = _feed[index];
              if (widget is PostWidget) {
                return PostWidget(
                  profileImage: widget.profileImage,
                  postType: widget.postType,
                  username: widget.username,
                  category: widget.category,
                  postImage: widget.postImage,
                  likes: widget.likes,
                  comments: widget.comments,
                  shares: widget.shares,
                  title: widget.title,
                  rating: widget.rating,
                  views: widget.views,
                  timeAgo: widget.timeAgo,
                  categoryIconImage: widget.categoryIconImage,
                  categoryColor: widget.categoryColor,
                  isSubscribed: widget.isSubscribed,
                  onSheetOpen: widget.onSheetOpen,
                  onSheetClose: widget.onSheetClose,
                );
              }
              return widget;
            }
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }
}
