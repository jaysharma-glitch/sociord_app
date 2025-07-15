// =====================
// PATCHED: Converted comments list to CommentModel usage
// =====================

import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/models/comment_model.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/home/comment_item.dart';
import 'package:sociord/widgets/home/comment_input_bar.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:http/http.dart' as http;
import 'package:sociord/constants/ui.dart';
import 'package:sociord/widgets/skeleton/skeleton_loader_comments.dart';

class CommentsBottomSheet extends StatefulWidget {
  final VoidCallback? onOpen;
  final VoidCallback? onClose;
  const CommentsBottomSheet({Key? key, this.onOpen, this.onClose})
    : super(key: key);

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  String replyingTo = '';
  int? replyingToIndex;
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final Map<int, bool> expandedReplies = {};
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _commentKeys = {};
  final ScrollController _commentsScrollController = ScrollController();
  late DraggableScrollableController _draggableController;

  final List<CommentModel> allComments = [
    CommentModel(
      profile: kCreator1,
      username: "carlosinmotion",
      timeAgo: "1 week ago",
      text: "Absolute legend. This dog just made my Monday brighter",
      gifUrl: null,
      likes: 500,
      type: CommentType.text,
      replies: [
        CommentModel(
          profile: kCreator2,
          username: "emiko_T",
          timeAgo: "9 Days ago",
          text: "Totally agree! Their happiness is so contagious! 🐶",
          gifUrl: null,
          likes: 50,
          type: CommentType.text,
        ),
        CommentModel(
          profile: kCreator3,
          username: "emiko_T",
          timeAgo: "9 Days ago",
          text:
              "@carlosinmotion Totally agree! Their happiness is so contagious! 🐶",
          gifUrl: null,
          likes: 50,
          type: CommentType.text,
        ),
      ],
    ),
    CommentModel(
      profile: kCreator3,
      username: "marie_louise_88",
      timeAgo: "7 Days ago",
      text: "@yoBitch So adorable! Makes me miss my childhood dog, Buddy.",
      gifUrl: null,
      likes: 550,
      type: CommentType.text,
      replies: [
        CommentModel(
          profile: kCreator4,
          username: "pia.vanhouten",
          timeAgo: "11 Days ago",
          text:
              "@emiko_T I showed this to my cat. She yawned and walked away. Classic.",
          gifUrl: null,
          likes: 15,
          type: CommentType.text,
        ),
      ],
    ),
  ];
  List<CommentModel> comments = [];
  bool isLoadingMore = false;
  bool hasMore = true;
  static const int commentsBatchSize = 20;
  static const int repliesBatchSize = 10;
  final Map<int, int> repliesShown = {}; // index -> number of replies shown
  final Map<int, bool> isLoadingReplies = {}; // index -> loading state
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _draggableController = DraggableScrollableController();
    _draggableController.addListener(_handleSheetDrag);
    _loadInitialComments();
    _scrollController.addListener(_onScroll);
    // Call onOpen after the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.onOpen != null) {
        debugPrint('CommentsBottomSheet: onOpen called');
        widget.onOpen!();
      }
    });
  }

  void _handleSheetDrag() {
    final size = _draggableController.size;
    if (size < 0.4) {
      if (widget.onClose != null) {
        debugPrint('CommentsBottomSheet: onClose called');
        widget.onClose!();
      }
      Navigator.of(context).maybePop();
    }
  }

  void _loadInitialComments() {
    setState(() {
      isLoading = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        comments = allComments.take(commentsBatchSize).toList();
        hasMore = allComments.length > commentsBatchSize;
        isLoading = false;
      });
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !isLoadingMore &&
        hasMore) {
      _loadMoreComments();
    }
  }

  Future<void> _loadMoreComments() async {
    setState(() {
      isLoadingMore = true;
    });
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    final nextIndex = comments.length;
    final nextBatch =
        allComments.skip(nextIndex).take(commentsBatchSize).toList();
    setState(() {
      comments.addAll(nextBatch);
      isLoadingMore = false;
      hasMore = allComments.length > comments.length;
    });
  }

  static const String kGiphyApiKey = 'E01F2hBjxYy086uTC0i00Wc8e6XVUkku';
  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _commentFocusNode.dispose();
    _draggableController.removeListener(_handleSheetDrag);
    _draggableController.dispose();
    // Don't call onClose here as it can cause setState during disposal
    super.dispose();
  }

  Future<List<GiphyGif>> fetchTrendingGifs() async {
    final client = GiphyClient(apiKey: kGiphyApiKey, randomId: 'sociord-user');
    final trending = await client.trending(limit: 10);
    return trending.data;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _draggableController,
      initialChildSize: 0.84,
      minChildSize: 0.6,
      maxChildSize: 0.84,
      snap: true,
      snapSizes: const [0.6, 0.84],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildDragHandle(),
              _buildTitle(context),
              _buildCommentsList(_commentsScrollController),
              SafeArea(
                top: false,
                bottom: false,
                minimum: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom - 30,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (replyingTo.isNotEmpty && replyingToIndex != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.asset(
                                comments[replyingToIndex!].profile,
                                height: 28,
                                width: 28,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Replying to ${comments[replyingToIndex!].username}',
                                style: Theme.of(context).textTheme.bodySmall!
                                    .copyWith(fontWeight: FontWeight.w500),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.close, size: 18),
                              onPressed: () {
                                setState(() {
                                  replyingTo = '';
                                  replyingToIndex = null;
                                  _commentController.clear();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                    CommentInputBar(
                      controller: _commentController,
                      replyingTo: replyingTo,
                      onSend: () {
                        final text = _commentController.text.trim();
                        if (text.isEmpty) return;
                        setState(() {
                          if (replyingToIndex != null) {
                            final parent = comments[replyingToIndex!];
                            parent.replies.add(
                              CommentModel(
                                profile: kCreator1,
                                username: 'current_user',
                                timeAgo: 'now',
                                text: text,
                                likes: 0,
                                likedByMe: false,
                                type: CommentType.text,
                              ),
                            );
                            repliesShown[replyingToIndex!] =
                                (repliesShown[replyingToIndex!] ??
                                    repliesBatchSize) +
                                1;
                            replyingTo = '';
                            replyingToIndex = null;
                          } else {
                            comments.insert(
                              0,
                              CommentModel(
                                profile: kCreator1,
                                username: 'current_user',
                                timeAgo: 'now',
                                text: text,
                                likes: 0,
                                likedByMe: false,
                                type: CommentType.text,
                              ),
                            );
                          }
                          _commentController.clear();
                        });
                      },
                      onGifTap: () async {
                        final gif = await showModalBottomSheet<GiphyGif?>(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            final double keyboardHeight =
                                MediaQuery.of(context).viewInsets.bottom;
                            TextEditingController searchController =
                                TextEditingController();
                            ValueNotifier<List<GiphyGif>> gifsNotifier =
                                ValueNotifier<List<GiphyGif>>([]);
                            ValueNotifier<bool> isSearching =
                                ValueNotifier<bool>(false);

                            // Fetch trending GIFs initially
                            fetchTrendingGifs().then(
                              (gifs) => gifsNotifier.value = gifs,
                            );

                            void searchGifs(String query) async {
                              if (query.isEmpty) {
                                gifsNotifier.value = await fetchTrendingGifs();
                                return;
                              }
                              isSearching.value = true;
                              final client = GiphyClient(
                                apiKey: kGiphyApiKey,
                                randomId: 'sociord-user',
                              );
                              final search = await client.search(
                                query,
                                limit: 30,
                              );
                              gifsNotifier.value = search.data;
                              isSearching.value = false;
                            }

                            return Container(
                              height: keyboardHeight + 450,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 6.0,
                                      right: 6.0,
                                      top: 12.0,
                                    ),
                                    child: SizedBox(
                                      height: 36,
                                      child: TextField(
                                        controller: searchController,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium!.copyWith(
                                          fontSize: 14,
                                          color: kAppBlack,
                                        ),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                vertical: 8,
                                                horizontal: 10,
                                              ),
                                          hintText: 'Search GIFs',
                                          hintStyle: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium!.copyWith(
                                            fontSize: 12,
                                            color: kAppBlack,
                                          ),
                                          prefixIcon: Icon(
                                            Icons.search,
                                            size: 18,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        onChanged: (query) => searchGifs(query),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ValueListenableBuilder<bool>(
                                      valueListenable: isSearching,
                                      builder: (context, searching, _) {
                                        if (searching) {
                                          return Center(
                                            child: kLoadingIndicator,
                                          );
                                        }
                                        return ValueListenableBuilder<
                                          List<GiphyGif>
                                        >(
                                          valueListenable: gifsNotifier,
                                          builder: (context, gifs, _) {
                                            if (gifs.isEmpty) {
                                              return const Center(
                                                child: Text('No GIFs found'),
                                              );
                                            }
                                            return GridView.builder(
                                              padding: const EdgeInsets.all(8),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 2,
                                                    crossAxisSpacing: 8,
                                                    mainAxisSpacing: 8,
                                                    childAspectRatio: 1,
                                                  ),
                                              itemCount: gifs.length,
                                              itemBuilder: (context, index) {
                                                final gif = gifs[index];
                                                return GestureDetector(
                                                  onTap:
                                                      () => Navigator.of(
                                                        context,
                                                      ).pop(gif),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    child: Image.network(
                                                      gif
                                                              .images
                                                              ?.fixedWidth
                                                              ?.url ??
                                                          '',
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                        if (gif != null) {
                          setState(() {
                            if (replyingToIndex != null) {
                              comments[replyingToIndex!].replies.add(
                                CommentModel(
                                  profile: kCreator1,
                                  username: 'current_user',
                                  timeAgo: 'now',
                                  gifUrl: gif.images?.original?.url,
                                  likes: 0,
                                  likedByMe: false,
                                  type: CommentType.gif,
                                ),
                              );
                              repliesShown[replyingToIndex!] =
                                  (repliesShown[replyingToIndex!] ??
                                      repliesBatchSize) +
                                  1;
                              replyingTo = '';
                              replyingToIndex = null;
                            } else {
                              comments.insert(
                                0,
                                CommentModel(
                                  profile: kCreator1,
                                  username: 'current_user',
                                  timeAgo: 'now',
                                  gifUrl: gif.images?.original?.url,
                                  likes: 0,
                                  likedByMe: false,
                                  type: CommentType.gif,
                                ),
                              );
                            }
                            _commentController.clear();
                          });
                        }
                      },
                      focusNode: _commentFocusNode,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      width: 40,
      height: 2,
      decoration: BoxDecoration(
        color: kAppBlack,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      "Comments",
      style: Theme.of(
        context,
      ).textTheme.headlineSmall!.copyWith(fontSize: 12, color: kAppBlack),
    );
  }

  Widget _buildCommentsList(ScrollController controller) {
    if (isLoading) {
      return const Expanded(child: SkeletonLoaderComments());
    }
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: comments.length,
              itemBuilder: (_, index) {
                final comment = comments[index];
                final showReplies = expandedReplies[index] ?? false;
                _commentKeys.putIfAbsent(index, () => GlobalKey());
                final totalReplies = comment.replies.length;
                final shownReplies = repliesShown[index] ?? repliesBatchSize;
                final isLoading = isLoadingReplies[index] ?? false;
                return Column(
                  key: _commentKeys[index],
                  children: [
                    CommentItem(
                      comment: comment,
                      onRespond: (handle) async {
                        setState(() {
                          replyingTo = handle;
                          replyingToIndex = index;
                          _commentController.text = '@$handle ';
                        });
                        final contextToScroll =
                            _commentKeys[index]?.currentContext;
                        if (contextToScroll != null) {
                          await Future.delayed(
                            const Duration(milliseconds: 100),
                          );
                          Scrollable.ensureVisible(
                            contextToScroll,
                            duration: const Duration(milliseconds: 300),
                            alignment: 0.8,
                          );
                        }
                      },
                      onToggleReplies: () {
                        setState(() {
                          expandedReplies[index] = !showReplies;
                          if (expandedReplies[index] == true &&
                              !repliesShown.containsKey(index)) {
                            repliesShown[index] = repliesBatchSize;
                          }
                        });
                      },
                      onLike: () {
                        setState(() {
                          comment.likedByMe = !comment.likedByMe;
                          comment.likes += comment.likedByMe ? 1 : -1;
                        });
                      },
                      showReplies: showReplies,
                    ),
                    if (showReplies) ...[
                      ...comment.replies
                          .take(shownReplies)
                          .toList()
                          .asMap()
                          .entries
                          .map<Widget>((entry) {
                            final reply = entry.value;
                            final replyIdx = entry.key;
                            return CommentItem(
                              comment: reply,
                              isReply: true,
                              onRespond: (handle) async {
                                setState(() {
                                  replyingTo = handle;
                                  replyingToIndex = index;
                                  _commentController.text = '@$handle ';
                                });
                                final contextToScroll =
                                    _commentKeys[index]?.currentContext;
                                if (contextToScroll != null) {
                                  await Future.delayed(
                                    const Duration(milliseconds: 100),
                                  );
                                  Scrollable.ensureVisible(
                                    contextToScroll,
                                    duration: const Duration(milliseconds: 300),
                                    alignment: 0.8,
                                  );
                                }
                              },
                              onLike: () {
                                setState(() {
                                  reply.likedByMe = !reply.likedByMe;
                                  reply.likes += reply.likedByMe ? 1 : -1;
                                });
                              },
                            );
                          })
                          .toList(),
                      if (shownReplies < totalReplies && !isLoading)
                        TextButton(
                          onPressed: () async {
                            setState(() {
                              isLoadingReplies[index] = true;
                            });
                            await Future.delayed(
                              const Duration(seconds: 1),
                            ); // Simulate network delay
                            setState(() {
                              repliesShown[index] =
                                  (repliesShown[index] ?? repliesBatchSize) +
                                  repliesBatchSize;
                              isLoadingReplies[index] = false;
                            });
                          },
                          child: const Text('View more replies'),
                        ),
                      if (isLoading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: kLoadingIndicator,
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
          if (isLoadingMore)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: kLoadingIndicator,
            ),
        ],
      ),
    );
  }
}
