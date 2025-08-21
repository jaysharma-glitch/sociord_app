import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/widgets/gradient_text.dart';
import 'package:sociord/widgets/home/comments_bottom_sheet.dart';
import 'package:sociord/widgets/home/ratings_bottom_sheet.dart';
import 'package:sociord/widgets/home/share_bottom_sheet.dart';
import 'package:sociord/widgets/common/profile_picture.dart';
import 'package:sociord/widgets/common/post_image.dart';

class PostWidget extends StatefulWidget {
  final String profileImage;
  final String postType;
  final String username;
  final String category;
  final String? collectionLink;
  final String postImage;
  final int likes;
  final int comments;
  final int shares;
  final String title;
  final String rating;
  final int views;
  final String timeAgo;
  final Color categoryColor;
  final String categoryIconImage;
  final bool isSubscribed;
  final VoidCallback? onSheetOpen;
  final VoidCallback? onSheetClose;

  const PostWidget({
    super.key,
    required this.profileImage,
    required this.postType,
    required this.username,
    required this.category,
    this.collectionLink,
    required this.postImage,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.title,
    required this.rating,
    required this.views,
    required this.timeAgo,
    required this.categoryColor,
    required this.categoryIconImage,
    this.isSubscribed = true,
    this.onSheetOpen,
    this.onSheetClose,
  });

  @override
  State<PostWidget> createState() => _PostComponentState();
}

class _PostComponentState extends State<PostWidget> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildPostImage(),
            _buildEngagementBar(context),
            _buildTitleAndMeta(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ProfilePicture(
                imageUrl: widget.profileImage,
                width: 40,
                height: 60,
                borderRadius: 5,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.username,
                        style: _headlineText(context, size: 12),
                      ),
                      const SizedBox(width: 10),
                      if (!widget.isSubscribed)
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 2,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            side: const BorderSide(
                              color: kAppBlack,
                              width: 0.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: Text(
                            "Subscribe",
                            style: _headlineText(context, size: 10),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _buildCategoryBadge(context),
                      if (widget.collectionLink != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          widget.collectionLink!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 12),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  GradientText(
                    text: widget.postType,
                    style: _headlineText(context, size: 10),
                    gradient: const LinearGradient(
                      colors: [kAppPurple, kAppOrange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          constraints: const BoxConstraints(),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.more_vert, size: 14),
        ),
      ],
    );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: widget.categoryColor,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        children: [
          Image.asset(widget.categoryIconImage, width: 12, color: kAppBlack),
          const SizedBox(width: 4),
          Column(
            children: [
              Text(
                widget.category,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage() {
    return PostImage(imageUrl: widget.postImage, borderRadius: 0);
  }

  Widget _buildEngagementBar(BuildContext context) {
    Color starColor =
        widget.rating == 'Excellent'
            ? kAppPurple
            : widget.rating == 'Good'
            ? kAppYellow
            : kAppBlack;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
      child: Row(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _openRatingsSheet(context),
                child: Icon(Icons.star_rounded, color: starColor, size: 22),
              ),
              const SizedBox(width: 4),
              Text(
                "${widget.likes}",
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
                "${widget.comments}",
                style: _bodyText(context, weight: FontWeight.w400),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              GestureDetector(
                onTap: () => _openShareSheet(context),
                child: const Icon(Icons.share, color: Colors.black54, size: 18),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndMeta(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Text(
            widget.title,
            style: _headlineText(context, color: kAppBlack, size: 15),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "Rated ${widget.rating} | ${widget.views} Views | ${widget.timeAgo}",
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _openCommentsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => CommentsBottomSheet(
            onOpen: widget.onSheetOpen,
            onClose: widget.onSheetClose,
          ),
    ).whenComplete(() {
      if (widget.onSheetClose != null) widget.onSheetClose!();
    });
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
      builder:
          (context) => RatingsBottomSheet(
            onOpen: widget.onSheetOpen,
            onClose: widget.onSheetClose,
          ),
    ).whenComplete(() {
      if (widget.onSheetClose != null) widget.onSheetClose!();
    });
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
      builder:
          (context) => ShareBottomSheet(
            onOpen: widget.onSheetOpen,
            onClose: widget.onSheetClose,
          ),
    ).whenComplete(() {
      if (widget.onSheetClose != null) widget.onSheetClose!();
    });
  }

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
}
