// =====================
// PATCHED: CommentItem now accepts CommentModel, not Map
// =====================

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/models/comment_model.dart';
import 'package:sociord/widgets/common/profile_picture.dart';

class CommentItem extends StatelessWidget {
  final CommentModel comment;
  final Function(String)? onRespond;
  final VoidCallback? onToggleReplies;
  final bool showReplies;
  final bool isReply;
  final VoidCallback? onLike;

  const CommentItem({
    super.key,
    required this.comment,
    this.onRespond,
    this.onToggleReplies,
    this.showReplies = false,
    this.isReply = false,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          isReply
              ? const EdgeInsets.only(left: 65, right: 15, top: 8, bottom: 8)
              : const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar (left)
          ProfilePicture(
            imageUrl: comment.profile,
            width: isReply ? 30 : 40,
            height: isReply ? 40 : 50,
            borderRadius: 5,
          ),
          const SizedBox(width: 10),
          // Right: Column with header, text, actions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username/timestamp/like/heart row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      comment.username,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.timeAgo,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${comment.likes}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall!.copyWith(fontSize: 12),
                    ),
                    const SizedBox(width: 3),
                    GestureDetector(
                      onTap: () {
                        if (onLike != null) onLike!();
                      },
                      child: Icon(
                        comment.likedByMe
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: comment.likedByMe ? kAppPurple : Colors.grey,
                        size: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                if (comment.type == CommentType.text && comment.text != null)
                  _buildRichCommentText(context, comment.text!)
                else if (comment.type == CommentType.gif &&
                    comment.gifUrl != null)
                  Image.network(comment.gifUrl!, height: 150),
                SizedBox(height: isReply ? 5 : 10),
                _buildActions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => onRespond?.call(comment.username),
          child: Text(
            "Respond",
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: 30),
        if (comment.replies.isNotEmpty)
          GestureDetector(
            onTap: onToggleReplies,
            child: Text(
              showReplies
                  ? "Hide replies"
                  : "View ${comment.replies.length} replies",
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: kAppPurple,
                fontWeight: FontWeight.w400,
                fontSize: 10,
                decoration: TextDecoration.underline,
                decorationThickness: 1,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRichCommentText(BuildContext context, String text) {
    final regex = RegExp(r'(@\w+)');
    final parts = text.splitMapJoin(
      regex,
      onMatch: (m) => '|||${m[0]}|||',
      onNonMatch: (n) => '<<<$n>>>',
    );

    final spans = <TextSpan>[];

    parts.split(RegExp(r'(?=\|\|\||<<<)')).forEach((chunk) {
      if (chunk.startsWith('|||')) {
        final mention = chunk.replaceAll('|||', '');
        spans.add(
          TextSpan(
            text: mention,
            style: _mentionTextStyle(context),
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () {
                    print("Navigate to \$mention's profile");
                  },
          ),
        );
      } else if (chunk.startsWith('<<<')) {
        final plain = chunk.replaceAll('<<<', '').replaceAll('>>>', '');
        spans.add(TextSpan(text: plain, style: _commentTextStyle(context)));
      }
    });

    return RichText(text: TextSpan(children: spans));
  }

  TextStyle _mentionTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
      fontWeight: FontWeight.w700,
      color: kAppPurple,
      fontSize: isReply ? 10 : 12,
    );
  }

  TextStyle _commentTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
      fontWeight: FontWeight.w400,
      fontSize: isReply ? 10 : 12,
    );
  }
}
