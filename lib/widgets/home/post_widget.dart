import 'package:flutter/material.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/widgets/gradient_text.dart';

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
  });

  @override
  State<PostWidget> createState() => _PostComponentState();
}

class _PostComponentState extends State<PostWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Profile, Username, Subscription Button, More Options
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(
                        widget.profileImage,
                        height: 60,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(widget.username,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(fontSize: 12, color: kAppBlack)),
                            const SizedBox(
                              width: 10,
                            ),
                            if (!widget.isSubscribed)
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 2),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  side: const BorderSide(
                                      color: kAppBlack, width: 0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: Text("Subscribe",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                            fontSize: 10, color: kAppBlack)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                  color: widget.categoryColor,
                                  borderRadius: BorderRadius.circular(2)),
                              child: Row(
                                children: [
                                  Image.asset(widget.categoryIconImage,
                                      width: 12, color: kAppBlack),
                                  const SizedBox(width: 4),
                                  Column(
                                    children: [
                                      Text(widget.category,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall!
                                              .copyWith(
                                                  fontWeight: FontWeight.w400)),
                                      const SizedBox(height: 1),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (widget.collectionLink != null) ...[
                              const SizedBox(width: 8),
                              Text(widget.collectionLink!,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple)),
                              const Icon(Icons.chevron_right, size: 12),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        GradientText(
                            text: widget.postType,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(fontSize: 10),
                            gradient: const LinearGradient(
                              colors: [kAppPurple, kAppOrange],
                              begin: Alignment
                                  .topLeft, // Gradient starts from top-left
                              end: Alignment
                                  .bottomRight, // Gradient ends at bottom-right
                            ))
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                  onPressed: () {},
                  constraints: BoxConstraints(),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.more_vert,
                    size: 14,
                  )),
            ],
          ),

          // Post Image
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Image.asset(widget.postImage,
                width: double.infinity, fit: BoxFit.cover),
          ),

          // Engagement: Likes, Comments, Shares
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
            child: Row(
              children: [
                Row(
                  children: [
                    Icon(Icons.star_rounded,
                        color: widget.rating == 'Excellent'
                            ? kAppPurple
                            : widget.rating == 'Good'
                                ? kAppYellow
                                : kAppBlack,
                        size: 22),
                    const SizedBox(width: 4),
                    Text(
                      "${widget.likes}",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    const Icon(Icons.chat_bubble,
                        color: Colors.black54, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      "${widget.comments}",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  children: [
                    const Icon(Icons.share, color: Colors.black54, size: 18),
                    const SizedBox(width: 4),
                  ],
                ),
              ],
            ),
          ),

          // Post Title and Meta Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(widget.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: kAppBlack, fontSize: 15)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            child: Text(
                "Rated ${widget.rating} | ${widget.views} Views | ${widget.timeAgo}",
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
