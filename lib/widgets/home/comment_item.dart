import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';

class CommentItem extends StatelessWidget {
  final Map<String, dynamic> comment;
  final Function(String)? onRespond;
  final VoidCallback? onToggleReplies;
  final bool showReplies;
  final bool isReply;

  const CommentItem({
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
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                  comment["profile"],
                  height: isReply ? 40 : 50,
                  width: isReply ? 30 : 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(comment["username"],
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontSize: isReply ? 10 : 12,
                                  color: kAppBlack,
                                )),
                        const SizedBox(width: 15),
                        Text(comment["timeAgo"],
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: kAppBlack.withOpacity(0.8),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 9,
                                    )),
                      ],
                    ),
                    const SizedBox(height: 2),
                    _buildRichCommentText(context, comment["text"]),
                    SizedBox(height: isReply ? 5 : 10),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => onRespond?.call(comment["username"]),
                          child: Text("Respond",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  )),
                        ),
                        const SizedBox(width: 30),
                        if (comment["replies"].isNotEmpty)
                          GestureDetector(
                            onTap: onToggleReplies,
                            child: Text(
                              showReplies
                                  ? "Hide replies"
                                  : "View ${comment["replies"].length} replies",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: kAppPurple,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 10,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 1,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 50),
              Text(comment["likes"].toString(),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(fontWeight: FontWeight.w400, fontSize: 10)),
              const SizedBox(width: 5),
              const Icon(Icons.favorite, color: kAppPurple, size: 14),
            ],
          ),
        ],
      ),
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
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: kAppPurple,
                  fontSize: isReply ? 10 : 12,
                ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // TODO: Handle @mention navigation
                print("Navigate to $mention's profile");
              },
          ),
        );
      } else if (chunk.startsWith('<<<')) {
        final plain = chunk.replaceAll('<<<', '').replaceAll('>>>', '');
        spans.add(
          TextSpan(
            text: plain,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: isReply ? 10 : 12,
                ),
          ),
        );
      }
    });

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
