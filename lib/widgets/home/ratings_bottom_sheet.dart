import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/mock_data/ratings_mock_data.dart';
import 'package:sociord/widgets/home/rating_list_item.dart';
import 'package:sociord/widgets/skeleton/skeleton_loader_ratings.dart';
import 'package:sociord/widgets/sociord_draggable_sheet.dart';

class RatingsBottomSheet extends StatefulWidget {
  final VoidCallback? onOpen;
  final VoidCallback? onClose;
  const RatingsBottomSheet({Key? key, this.onOpen, this.onClose})
    : super(key: key);

  @override
  State<RatingsBottomSheet> createState() => _RatingsBottomSheetState();
}

class _RatingsBottomSheetState extends State<RatingsBottomSheet> {
  static const int batchSize = 30;
  final String currentUserId = '1'; // For mock/demo
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<MockRating> ratings = [];
  bool isLoading = false;
  bool hasMore = true;
  String search = '';
  String? error;
  int userRating = 0;
  bool isSending = false;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    _fetchInitial();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.onOpen != null) {
        debugPrint('RatingsBottomSheet: onOpen called');
        widget.onOpen!();
      }
    });
  }

  Future<void> _fetchInitial() async {
    setState(() {
      isLoading = true;
      error = null;
      ratings = [];
      hasMore = true;
    });
    try {
      final batch = await fetchRatingsBatch(
        0,
        batchSize,
        currentUserId,
        search: search.isNotEmpty ? search : null,
      );
      setState(() {
        ratings = batch;
        hasMore = batch.length == batchSize;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'App is facing some issues, try again later';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchMore() async {
    if (!hasMore || isLoading) return;
    setState(() => isLoading = true);
    try {
      final batch = await fetchRatingsBatch(
        ratings.length,
        batchSize,
        currentUserId,
        search: search.isNotEmpty ? search : null,
      );
      setState(() {
        ratings.addAll(batch);
        hasMore = batch.length == batchSize;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'App is facing some issues, try again later';
        isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        hasMore &&
        !isLoading) {
      _fetchMore();
    }
  }

  void _onSearchChanged() {
    final val = _searchController.text;
    if (val.length > 2 || val.isEmpty) {
      setState(() => search = val);
      _fetchInitial();
    }
  }

  void _onSendRating() async {
    setState(() => isSending = true);
    await Future.delayed(Duration(milliseconds: 600)); // Simulate send
    setState(() => isSending = false);
    // Add/update user's rating at the top
    final idx = ratings.indexWhere((r) => r.userId == currentUserId);
    final userMock = MockRating(
      userImage: 'assets/images/creator/1.jpeg',
      userName: 'carlosinmotion',
      userId: currentUserId,
      rating: userRating,
    );
    if (idx >= 0) {
      ratings[idx] = userMock;
    } else {
      ratings.insert(0, userMock);
    }
    setState(() {});
  }

  void _onDeleteRating() async {
    setState(() => isDeleting = true);
    await Future.delayed(Duration(milliseconds: 400));
    ratings.removeWhere((r) => r.userId == currentUserId);
    setState(() {
      userRating = 0;
      isDeleting = false;
    });
  }

  @override
  void dispose() {
    if (widget.onClose != null) {
      debugPrint('RatingsBottomSheet: onClose called');
      widget.onClose!();
    }
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userOwn = ratings.firstWhere(
      (r) => r.userId == currentUserId,
      orElse:
          () => MockRating(
            userImage: '',
            userName: '',
            userId: currentUserId,
            rating: 0,
          ),
    );
    final showList =
        ratings
            .where((r) => r.rating >= 3 || r.userId == currentUserId)
            .toList();
    final notEnough = showList.where((r) => r.rating >= 3).isEmpty;
    return SociordDraggableSheet(
      minChildSize: 0.6,
      maxChildSize: 0.88,
      onOpen: widget.onOpen,
      onClose: widget.onClose,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.88,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 43,
              height: 2,
              decoration: BoxDecoration(
                color: kAppBlack,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ratings',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: kAppBlack,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 33,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _onSearchChanged(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(color: kAppBlack),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search usernames',
                    hintStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: kAppBlack.withOpacity(0.5),
                    ),
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  error != null
                      ? Center(
                        child: Text(
                          error!,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(color: Colors.red),
                        ),
                      )
                      : isLoading
                      ? const SkeletonLoaderRatings()
                      : notEnough
                      ? Center(
                        child: Text(
                          'Not enough ratings to show',
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: Colors.grey[700], fontSize: 16),
                        ),
                      )
                      : ListView.builder(
                        controller: _scrollController,
                        itemCount: showList.length + (hasMore ? 1 : 0),
                        itemBuilder: (context, idx) {
                          if (idx == showList.length) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            );
                          }
                          final r = showList[idx];
                          return RatingListItem(
                            rating: r,
                            isCurrentUser: r.userId == currentUserId,
                            onDelete:
                                r.userId == currentUserId
                                    ? () async {
                                      Feedback.forLongPress(context);
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (ctx) => AlertDialog(
                                              title: Text(
                                                'Delete your rating?',
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.titleMedium,
                                              ),
                                              content: Text(
                                                'Are you sure you want to delete your rating?',
                                                style:
                                                    Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        ctx,
                                                        false,
                                                      ),
                                                  child: Text(
                                                    'Cancel',
                                                    style:
                                                        Theme.of(
                                                          context,
                                                        ).textTheme.bodyMedium,
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        ctx,
                                                        true,
                                                      ),
                                                  child: Text(
                                                    'Delete',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium!
                                                        .copyWith(
                                                          color: Colors.red,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );
                                      if (confirm == true) _onDeleteRating();
                                    }
                                    : null,
                          );
                        },
                      ),
            ),
            Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  if (userOwn.userImage.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(
                        userOwn.userImage,
                        height: 32,
                        width: 32,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Icon(
                      Icons.account_circle,
                      size: 32,
                      color: Colors.grey[400],
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (userRating > 0)
                          Text(
                            'Your Rating : ${getRatingDisplay(userRating).keyword.replaceFirst('Rated ', '')}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: kAppBlack.withOpacity(0.75),
                            ),
                          ),
                        Row(
                          children: List.generate(5, (i) {
                            final idx = i + 1;
                            final color =
                                userRating == 0
                                    ? Colors.grey[300]
                                    : getRatingDisplay(userRating).color;
                            return GestureDetector(
                              onTap: () => setState(() => userRating = idx),
                              child: Icon(
                                idx <= userRating
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color:
                                    idx <= userRating
                                        ? color
                                        : Colors.grey[300],
                                size: 24,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  isSending
                      ? SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color:
                              userRating > 0 && !isSending
                                  ? kAppPurple
                                  : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          onPressed:
                              userRating > 0 && !isSending
                                  ? _onSendRating
                                  : null,
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
