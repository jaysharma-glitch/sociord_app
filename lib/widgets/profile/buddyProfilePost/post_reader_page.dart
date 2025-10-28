import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'post_model.dart';
import 'post_repo.dart';
import 'post_card.dart';
import 'post_source.dart';
import 'mock_post_repo.dart';
import 'package:sociord/widgets/common/profile_picture.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/common/options_bottom_sheet.dart';

class PostReaderPage extends StatefulWidget {
  final String userId;
  final String initialPostId;
  final PostSource source;
  final List<Post>? prefetched; // optional: newest→oldest
  final String? userName;
  final String? profileImage;
  final bool isCreator; // Add parameter to determine account type

  const PostReaderPage({
    super.key,
    required this.userId,
    required this.initialPostId,
    required this.source,
    this.prefetched,
    this.userName,
    this.profileImage,
    this.isCreator = false, // Default to personal account
  });

  @override
  State<PostReaderPage> createState() => _PostReaderPageState();
}

class _PostReaderPageState extends State<PostReaderPage> {
  final ScrollController _scroll = ScrollController();
  late final PostRepo _repo = MockPostRepo(); // Using mock repo for now
  List<Post> _feed = [];
  bool _loadingMore = false;
  DateTime? _oldestLoadedAt; // for pagination

  @override
  void initState() {
    super.initState();
    _init();
    _scroll.addListener(_onScrollEndLoadMore);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    // For debugging - print the parameters
    print(
      'PostReaderPage _init: userId=${widget.userId}, initialPostId=${widget.initialPostId}, source=${widget.source}',
    );

    final newestToOldest =
        widget.prefetched ??
        await _repo.fetchUserPosts(
          userId: widget.userId,
          source: widget.source,
          limit: 30,
        );

    // For debugging - print the fetched posts
    print('PostReaderPage _init: fetched ${newestToOldest.length} posts');
    for (var post in newestToOldest) {
      print('  - ${post.id}: ${post.caption}');
    }

    if (newestToOldest.isEmpty) {
      print('PostReaderPage _init: No posts found, setting empty feed');
      setState(() => _feed = []);
      return;
    }

    // Reorder: [selected] + [all newest→oldest except selected]
    final selected = newestToOldest.firstWhere(
      (p) => p.id == widget.initialPostId,
      orElse: () => newestToOldest.first, // fallback if not found
    );
    final rest = newestToOldest.where((p) => p.id != selected.id).toList();

    print(
      'PostReaderPage _init: Selected post: ${selected.id}, Rest posts: ${rest.length}',
    );

    setState(() {
      _feed = [selected, ...rest];
      _oldestLoadedAt = newestToOldest.last.createdAt;
    });

    print('PostReaderPage _init: Final feed has ${_feed.length} posts');
  }

  void _onScrollEndLoadMore() {
    if (_loadingMore) return;
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    final pos = _scroll.position.pixels;
    if (max - pos < 600) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_oldestLoadedAt == null) return;
    setState(() => _loadingMore = true);

    final older = await _repo.fetchUserPosts(
      userId: widget.userId,
      source: widget.source,
      limit: 30,
      before: _oldestLoadedAt,
    );

    if (older.isNotEmpty) {
      // Dedup by id (especially the selected one)
      final existing = _feed.map((p) => p.id).toSet();
      final deduped = older.where((p) => !existing.contains(p.id)).toList();
      setState(() {
        _feed.addAll(deduped); // older are already newest→oldest relative
        _oldestLoadedAt = older.last.createdAt;
      });
    }

    setState(() => _loadingMore = false);
  }

  bool _isVideoVisible(int index) {
    if (index >= _feed.length) return false;
    final post = _feed[index];
    if (post.mediaType != MediaType.video) return false;

    // Simple visibility check - assume first few videos are visible
    // In a real implementation, you'd use IntersectionObserver or similar
    return index < 3; // Only first 3 videos auto-play for now
  }

  void _openSociordOptions(BuildContext context) {
    OptionsBottomSheet.show(
      context: context,
      type:
          widget.isCreator
              ? BottomSheetType.selfPostCreator
              : BottomSheetType.selfPostPersonal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scroll,
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: false,
            backgroundColor: kAppWhite,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                // Sociord logo with dropdown
                GestureDetector(
                  onTap: () => _openSociordOptions(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(kLogoText, height: 28),
                      const SizedBox(width: 5),
                      Image.asset(kChevronDown),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                if (widget.profileImage != null) ...[
                  ProfilePicture(
                    imageUrl: widget.profileImage!,
                    width: 40,
                    height: 50,
                    borderRadius: 5,
                  ),
                  const SizedBox(width: 12),
                ],
                Flexible(
                  fit: FlexFit.loose,
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // don't force extra height
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName ?? "Arjun's Posts",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "@arjun.sethi",
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          // Feed
          SliverList.builder(
            itemCount: _feed.length,
            itemBuilder: (context, i) {
              // For debugging
              if (i == 0) {
                print('PostReaderPage build: Rendering ${_feed.length} posts');
              }
              print(
                'PostReaderPage build: Rendering post ${i + 1}/${_feed.length}: ${_feed[i].id}',
              );

              return PostCard(
                post: _feed[i],
                userName: widget.userName,
                profileImage: widget.profileImage,
                showProfile: false, // Hide profile since it's in app bar
                autoPlay: _isVideoVisible(i),
                onProfileTap: () {
                  // Handle profile tap
                },
                onLikeChanged: (updatedPost) {
                  // Handle like change
                  print('Post ${updatedPost.id} liked: ${updatedPost.liked}');
                },
                onMessageSend: (message) {
                  // Handle message send
                  print('Message sent: $message');
                },
              );
            },
          ),

          // Loading more indicator
          if (_loadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
