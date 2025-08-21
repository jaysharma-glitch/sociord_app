import 'package:flutter/material.dart';
import 'post_model.dart';
import 'post_repo.dart';
import 'post_source.dart';
import 'post_card.dart';
import 'mock_post_repo.dart';
import 'package:sociord/widgets/common/profile_picture.dart';

class PostReaderPage extends StatefulWidget {
  final String userId;
  final String initialPostId;
  final PostSource source;
  final List<Post>? prefetched; // optional: newest→oldest
  final String? userName;
  final String? profileImage;

  const PostReaderPage({
    super.key,
    required this.userId,
    required this.initialPostId,
    required this.source,
    this.prefetched,
    this.userName,
    this.profileImage,
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
    final newestToOldest =
        widget.prefetched ??
        await _repo.fetchUserPosts(
          userId: widget.userId,
          source: widget.source,
          limit: 30,
        );

    if (newestToOldest.isEmpty) {
      setState(() => _feed = []);
      return;
    }

    // Reorder: [selected] + [all newest→oldest except selected]
    final selected = newestToOldest.firstWhere(
      (p) => p.id == widget.initialPostId,
      orElse: () => newestToOldest.first, // fallback if not found
    );
    final rest = newestToOldest.where((p) => p.id != selected.id).toList();

    setState(() {
      _feed = [selected, ...rest];
      _oldestLoadedAt = newestToOldest.last.createdAt;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: false,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                if (widget.profileImage != null) ...[
                  ProfilePicture(
                    imageUrl: widget.profileImage!,
                    imageSize: 40,
                    borderRadius: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName ?? "Arjun's Posts",
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.black),
                      ),
                      Text(
                        "@arjun.sethi",
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: Colors.black54),
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
            itemBuilder:
                (context, i) => PostCard(
                  post: _feed[i],
                  userName: widget.userName,
                  profileImage: widget.profileImage,
                  showProfile: false, // Hide profile since it's in app bar
                  onProfileTap: () {
                    // Handle profile tap
                  },
                  onLikeTap: () {
                    // Handle like tap
                  },
                  onMessageSend: (message) {
                    // Handle message send
                    print('Message sent: $message');
                  },
                ),
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
