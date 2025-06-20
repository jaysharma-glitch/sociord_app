// =====================
// PATCHED: Converted comments list to CommentModel usage
// =====================

import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/models/comment_model.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/home/comment_item.dart';
import 'package:sociord/widgets/home/comment_input_bar.dart';

class CommentsBottomSheet extends StatefulWidget {
  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  String replyingTo = '';
  final TextEditingController _commentController = TextEditingController();
  final Map<int, bool> expandedReplies = {};

  final List<CommentModel> comments = [
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
        )
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
        )
      ],
    )
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 1,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildDragHandle(),
            _buildTitle(context),
            _buildCommentsList(controller),
            CommentInputBar(
              controller: _commentController,
              replyingTo: replyingTo,
              onSend: () {
                setState(() {
                  replyingTo = '';
                  _commentController.clear();
                });
              },
              onGifTap: () {
                // to implement
              },
            ),
          ],
        ),
      ),
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
      style: Theme.of(context)
          .textTheme
          .headlineSmall!
          .copyWith(fontSize: 12, color: kAppBlack),
    );
  }

  Widget _buildCommentsList(ScrollController controller) {
    return Expanded(
      child: ListView.builder(
        controller: controller,
        itemCount: comments.length,
        itemBuilder: (_, index) {
          final comment = comments[index];
          final showReplies = expandedReplies[index] ?? false;

          return Column(
            children: [
              CommentItem(
                comment: comment,
                onRespond: (handle) {
                  setState(() {
                    replyingTo = handle;
                    _commentController.text = '@$handle ';
                  });
                },
                onToggleReplies: () {
                  setState(() {
                    expandedReplies[index] = !showReplies;
                  });
                },
                showReplies: showReplies,
              ),
              if (showReplies)
                ...comment.replies.map<Widget>((reply) {
                  return CommentItem(comment: reply, isReply: true);
                }).toList(),
            ],
          );
        },
      ),
    );
  }
}
