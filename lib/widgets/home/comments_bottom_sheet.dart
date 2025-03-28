import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/home/comment_item.dart';

class CommentsBottomSheet extends StatefulWidget {
  @override
  _CommentsBottomSheetState createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  String replyingTo = ''; // ✅ Stores handle of the user being replied to
  TextEditingController _commentController = TextEditingController();
  Map<int, bool> expandedReplies = {}; // ✅ Stores expanded/collapsed state

  List<Map<String, dynamic>> comments = [
    {
      "profile": kCreator1,
      "username": "carlosinmotion",
      "timeAgo": "1 week ago",
      "text": "Absolute legend. This dog just made my Monday brighter",
      "likes": 500,
      "replies": [
        {
          "profile": kCreator2,
          "username": "emiko_T",
          "timeAgo": "9 Days ago",
          "text": "Totally agree! Their happiness is so contagious! 🐶",
          "likes": 50,
          "replies": [],
        },
        {
          "profile": kCreator3,
          "username": "emiko_T",
          "timeAgo": "9 Days ago",
          "text":
              "@carlosinmotion Totally agree! Their happiness is so contagious! 🐶",
          "likes": 50,
          "replies": [],
        }
      ],
    },
    {
      "profile": kCreator3,
      "username": "marie_louise_88",
      "timeAgo": "7 Days ago",
      "text": "@yoBitch So adorable! Makes me miss my childhood dog, Buddy.",
      "likes": 550,
      "replies": [
        {
          "profile": kCreator4,
          "username": "pia.vanhouten",
          "timeAgo": "11 Days ago",
          "text":
              "@emiko_T I showed this to my cat. She yawned and walked away. Classic.",
          "likes": 15,
          "replies": [],
        }
      ],
    }
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85, // ✅ Starts at 80% of screen
      minChildSize: 0.5, // ✅ Minimum is 50%
      maxChildSize: 1, // ✅ Can be dragged to 95%
      expand: false,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Drag Indicator
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 2,
              decoration: BoxDecoration(
                color: kAppBlack,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Comments Title
            Text("Comments",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontSize: 12, color: kAppBlack)),

            // Comments Section
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: comments.length,
                itemBuilder: (_, index) {
                  return Column(
                    children: [
                      CommentItem(
                        comment: comments[index],
                        onRespond: (handle) {
                          setState(() {
                            replyingTo = handle;
                            _commentController.text = '@$handle ';
                          });
                        },
                        onToggleReplies: () {
                          setState(() {
                            expandedReplies[index] =
                                !(expandedReplies[index] ?? false);
                          });
                        },
                        showReplies: expandedReplies[index] ?? false,
                      ),

                      // Show Replies
                      if (expandedReplies[index] == true)
                        ...comments[index]["replies"].map<Widget>((reply) {
                          return CommentItem(
                            comment: reply,
                            isReply: true,
                          );
                        }).toList(),
                    ],
                  );
                },
              ),
            ),

            // Comment Input Field
            // Comment Input Field
            Container(
              color: kAppLightGreay,
              padding: const EdgeInsets.only(bottom: 30),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(
                        kProfilePic,
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: 80, // about 3 lines
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          reverse: true,
                          child: TextField(
                            controller: _commentController,
                            decoration: InputDecoration(
                              hintText: replyingTo.isEmpty
                                  ? 'Your Comment'
                                  : 'Replying to @$replyingTo',
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10),
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(fontWeight: FontWeight.w400),
                            maxLines: null,
                            minLines: 1,
                            keyboardType: TextInputType.multiline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.face, color: kAppBlack),
                    const SizedBox(width: 5),
                    FloatingActionButton(
                      shape: const CircleBorder(),
                      mini: true,
                      backgroundColor: kAppPurple,
                      onPressed: () {
                        setState(() {
                          replyingTo = '';
                          _commentController.clear();
                        });
                      },
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
