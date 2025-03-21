import 'package:flutter/material.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/home/feed_slider.dart';
import 'package:sociord/widgets/home/post_widget.dart';
import 'package:sociord/widgets/home/quicky_recommendation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  List<dynamic> _feed = [];
  int _page = 1;
  bool _alternateRecommendation = false; // ✅ Keeps track of alternation

  @override
  void initState() {
    super.initState();
    _fetchInitialPosts();
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

  Future<void> _fetchInitialPosts() async {
    setState(() {
      _feed = [
        FeedSlider(), // ✅ Always at the top
        _buildFirstRecommendation(), // ✅ First recommendation always after slider
        ..._generateStaticData(), // ✅ Populate with mock data
      ];
    });
  }

  Future<void> _fetchMorePosts() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    await Future.delayed(const Duration(seconds: 2)); // Simulating API call

    setState(() {
      _feed.addAll(_generateStaticData());
      _isLoadingMore = false;
      _page++;
    });
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _feed = [
        FeedSlider(),
        _buildFirstRecommendation(),
        ..._generateStaticData(),
      ];
      _page = 1;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore) {
      _fetchMorePosts();
    }
  }

  Widget _buildFirstRecommendation() {
    return HomePageRecommendation(
      type: 'Quicky',
      userName: 'Arjun',
      onDismiss: () {},
      recommendations: const [
        {"image": kQuicky1, "title": "My Royal Transformation"},
        {"image": kQuicky2, "title": "Exploring Cheese"},
        {"image": kQuicky3, "title": "The Modern Man’s..."}
      ],
    );
  }

  bool _shouldShowRecommendation(int page) {
    if (page <= 4) {
      return page % 2 == 0; // ✅ Show every 2 pages for first 4 pages
    } else if (page <= 10) {
      return page % 5 == 0; // ✅ Show every 5 pages after page 4
    } else if (page <= 20) {
      return page % 10 == 0; // ✅ Show every 10 pages after page 10
    }
    return false; // ✅ Stop after page 20
  }

  List<dynamic> _generateStaticData() {
    List<dynamic> data = [
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
        categoryColor: Color(0xFFFA7921).withOpacity(0.5),
        isSubscribed: false,
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
        categoryColor: Color(0xFFFA2189).withOpacity(0.5),
        isSubscribed: true,
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
        categoryColor: Color(0xFF6621FA).withOpacity(0.5),
        isSubscribed: true,
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
        categoryColor: Color(0xFF9DD6FF).withOpacity(0.5),
        isSubscribed: false,
      ),
      PostWidget(
        profileImage: kCreator8,
        postType: 'Clips',
        username: "nomad_in_the_city",
        category: "Music, Dance & Performance",
        postImage: kPost5,
        likes: 2000000,
        comments: 5000000,
        shares: 1000,
        title: "The Soundscape Experience",
        rating: "Excellent",
        views: 20000000,
        timeAgo: "45 days ago",
        categoryIconImage: kUtensils,
        categoryColor: Color(0xFFFA218980).withOpacity(0.5),
        isSubscribed: true,
      ),
    ];

    if (_shouldShowRecommendation(_page)) {
      data.insert(
        2,
        HomePageRecommendation(
          type: _alternateRecommendation ? 'Quicky' : 'Creator',
          userName: 'Arjun',
          onDismiss: () {},
          recommendations: _alternateRecommendation
              ? const [
                  {"image": kQuicky1, "title": "My Royal Transformation"},
                  {"image": kQuicky2, "title": "Exploring Cheese"},
                  {"image": kQuicky3, "title": "The Modern Man’s..."}
                ]
              : const [
                  {"image": kCreator5, "title": "ninapetrov"},
                  {"image": kCreator6, "title": "fitandfearless"},
                  {"image": kCreator7, "title": "bechamonfield"}
                ],
        ),
      );

      _alternateRecommendation = !_alternateRecommendation; // ✅ Toggle
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {},
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(
                kLogoText,
                height: 28,
              ),
              const SizedBox(width: 5),
              Image.asset(kChevronDown)
            ],
          ),
        ),
        backgroundColor: kAppWhite,
        actions: [
          GestureDetector(
            onTap: () {},
            child: Image.asset(kNotification),
          ),
          const SizedBox(width: 15),
          GestureDetector(
            onTap: () {},
            child: Image.asset(kMessage),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _feed.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _feed.length) {
              return _feed[index];
            } else {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
        ),
      ),
    );
  }
}
