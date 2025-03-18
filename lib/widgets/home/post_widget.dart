import 'package:flutter/material.dart';
import 'package:sociord/utils/app_constants.dart';

class PostWidget extends StatefulWidget {
  final String profileImage;
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
  final bool isSubscribed;

  const PostWidget({
    super.key,
    required this.profileImage,
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
    this.isSubscribed = false,
  });

  @override
  State<PostWidget> createState() => _PostComponentState();
}

class _PostComponentState extends State<PostWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Profile, Username, Subscription Button, More Options
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(widget.profileImage, height: 50),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.username,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontSize: 12, color: kAppBlack)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                              color: widget.categoryColor,
                              borderRadius: BorderRadius.circular(5)),
                          child: Row(
                            children: [
                              const Icon(Icons.category,
                                  size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(widget.category,
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.white)),
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
                  ],
                ),
              ),
              if (widget.isSubscribed)
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      backgroundColor: Colors.black,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: const Text("Subscribe",
                      style: TextStyle(fontSize: 12, color: Colors.white)),
                ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
            ],
          ),
        ),

        // Post Image
        ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: Image.asset(widget.postImage,
              width: double.infinity, fit: BoxFit.cover),
        ),

        // Engagement: Likes, Comments, Shares
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.purple, size: 18),
                  const SizedBox(width: 4),
                  Text("${widget.likes}"),
                ],
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  const Icon(Icons.chat_bubble,
                      color: Colors.black54, size: 18),
                  const SizedBox(width: 4),
                  Text("${widget.comments}"),
                ],
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  const Icon(Icons.share, color: Colors.black54, size: 18),
                  const SizedBox(width: 4),
                  Text("${widget.shares}"),
                ],
              ),
            ],
          ),
        ),

        // Post Title and Meta Info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(widget.title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Text(
              "Rated ${widget.rating} | ${widget.views} Views | ${widget.timeAgo}",
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
