// =====================
// PATCHED: CommentItem now accepts CommentModel, not Map
// =====================

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/models/comment_model.dart';

class CommentItem extends StatelessWidget {
  final CommentModel comment;
  final Function(String)? onRespond;
  final VoidCallback? onToggleReplies;
  final bool showReplies;
  final bool isReply;

  const CommentItem({
    super.key,
    required this.comment,
    this.onRespond,
    this.onToggleReplies,
    this.showReplies = false,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: isReply
          ? const EdgeInsets.only(left: 65, right: 15, top: 8, bottom: 8)
          : const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildProfileImage(),
              const SizedBox(width: 10),
              Expanded(child: _buildCommentContent(context)),
              const SizedBox(width: 10),
              _buildLikes(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Image.asset(
        comment.profile,
        height: isReply ? 40 : 50,
        width: isReply ? 30 : 40,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildCommentContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 2),
        if (comment.type == CommentType.text && comment.text != null)
          _buildRichCommentText(context, comment.text!)
        else if (comment.type == CommentType.gif && comment.gifUrl != null)
          Image.network(comment.gifUrl!, height: 150),
        SizedBox(height: isReply ? 5 : 10),
        _buildActions(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          comment.username,
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontSize: isReply ? 10 : 12,
                color: kAppBlack,
              ),
        ),
        const SizedBox(width: 15),
        Text(
          comment.timeAgo,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: kAppBlack.withOpacity(0.8),
                fontWeight: FontWeight.w400,
                fontSize: 9,
              ),
        ),
      ],
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

  Widget _buildLikes(BuildContext context) {
    return Row(
      children: [
        Text(
          comment.likes.toString(),
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontWeight: FontWeight.w400,
                fontSize: 10,
              ),
        ),
        const SizedBox(width: 5),
        const Icon(Icons.favorite, color: kAppPurple, size: 14),
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
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                print("Navigate to \$mention's profile");
              },
          ),
        );
      } else if (chunk.startsWith('<<<')) {
        final plain = chunk.replaceAll('<<<', '').replaceAll('>>>', '');
        spans.add(
          TextSpan(
            text: plain,
            style: _commentTextStyle(context),
          ),
        );
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
