import 'package:flutter/material.dart';
import 'package:sociord/mock_data/share_mock_data.dart';
import 'package:sociord/widgets/home/share_user_grid_item.dart';
import 'package:sociord/widgets/skeleton/skeleton_loader_share.dart';
import 'package:sociord/utils/asset_path_constants.dart';

class ShareBottomSheet extends StatefulWidget {
  final VoidCallback? onOpen;
  final VoidCallback? onClose;
  const ShareBottomSheet({Key? key, this.onOpen, this.onClose})
    : super(key: key);

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet>
    with SingleTickerProviderStateMixin {
  static const int batchSize = 30;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  List<MockShareUser> users = [];
  Set<String> selectedUserIds = {};
  bool isLoading = false;
  bool hasMore = true;
  String search = '';
  String? error;
  bool showNoteInput = false;
  late AnimationController _animController;
  late Animation<double> _slideAnim;
  late DraggableScrollableController _draggableController;

  @override
  void initState() {
    super.initState();
    _draggableController = DraggableScrollableController();
    _draggableController.addListener(_handleSheetDrag);
    _fetchInitial();
    _scrollController.addListener(_onScroll);
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    _slideAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.onOpen != null) {
        debugPrint('ShareBottomSheet: onOpen called');
        widget.onOpen!();
      }
    });
  }

  Future<void> _fetchInitial() async {
    setState(() {
      isLoading = true;
      error = null;
      users = [];
      hasMore = true;
    });
    try {
      final batch = await fetchShareUsersBatch(
        0,
        batchSize,
        search: search.isNotEmpty ? search : null,
      );
      setState(() {
        users = batch;
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
      final batch = await fetchShareUsersBatch(
        users.length,
        batchSize,
        search: search.isNotEmpty ? search : null,
      );
      setState(() {
        users.addAll(batch);
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

  void _onUserTap(MockShareUser user) {
    setState(() {
      if (selectedUserIds.contains(user.userId)) {
        selectedUserIds.remove(user.userId);
      } else {
        selectedUserIds.add(user.userId);
      }
      if (selectedUserIds.isNotEmpty) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  void _handleSheetDrag() {
    final size = _draggableController.size;
    if (size < 0.6) {
      if (widget.onClose != null) {
        debugPrint('ShareBottomSheet: onClose called');
        widget.onClose!();
      }
      Navigator.of(context).maybePop();
    }
  }

  @override
  void dispose() {
    _draggableController.removeListener(_handleSheetDrag);
    _draggableController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _noteController.dispose();
    _animController.dispose();
    // Don't call onClose here as it can cause setState during disposal
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showNote = selectedUserIds.isNotEmpty;
    final gridCount = MediaQuery.of(context).size.width > 400 ? 3 : 2;
    return DraggableScrollableSheet(
      controller: _draggableController,
      initialChildSize: 0.84,
      minChildSize: 0.6,
      maxChildSize: 0.84,
      snap: true,
      snapSizes: [0.6, 0.84],
      builder: (context, scrollController) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
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
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Share it with a buddy',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
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
                    style: Theme.of(context).textTheme.titleSmall,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search usernames or names',
                      hintStyle: Theme.of(context).textTheme.titleSmall!
                          .copyWith(color: Colors.black.withOpacity(0.5)),
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
                        ? const SkeletonLoaderShare()
                        : GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.8,
                              ),
                          itemCount: users.length,
                          itemBuilder: (context, idx) {
                            final user = users[idx];
                            return ShareUserGridItem(
                              user: user,
                              selected: selectedUserIds.contains(user.userId),
                              onTap: () => _onUserTap(user),
                            );
                          },
                        ),
              ),
              Stack(
                children: [
                  // Share options row (always visible)
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 10,
                      bottom: 35,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Image.asset(kShareLink, width: 28, height: 28),
                            SizedBox(height: 4),
                            Text(
                              'Copy Link',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Image.asset(kShareWhatsapp, width: 28, height: 28),
                            SizedBox(height: 4),
                            Text(
                              'Whatsapp',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Image.asset(kShareSlack, width: 28, height: 28),
                            SizedBox(height: 4),
                            Text(
                              'Slack',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Image.asset(kShareInstagram, width: 28, height: 28),
                            SizedBox(height: 4),
                            Text(
                              'Instagram',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Image.asset(kShareMessenger, width: 28, height: 28),
                            SizedBox(height: 4),
                            Text(
                              'Messenger',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Animated message input (slides up to cover share options)
                  Positioned.fill(
                    child: IgnorePointer(
                      ignoring: !showNote,
                      child: AnimatedOpacity(
                        opacity: showNote ? 1 : 0,
                        duration: Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child:
                            showNote
                                ? Container(
                                  color: Colors.grey[100],
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 16,
                                    top: 10,
                                    bottom: 35,
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Image.asset(
                                          'assets/images/profileImage.png',
                                          height: 32,
                                          width: 32,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: _noteController,
                                          minLines: 1,
                                          maxLines: 4,
                                          style:
                                              Theme.of(
                                                context,
                                              ).textTheme.bodyMedium,
                                          decoration: InputDecoration(
                                            hintText: 'Add a note ?',
                                            hintStyle: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium!.copyWith(
                                              color: Colors.black.withOpacity(
                                                0.5,
                                              ),
                                            ),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          icon: Icon(
                                            Icons.send_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          onPressed: () {
                                            // TODO: Send share to selected users with note
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
