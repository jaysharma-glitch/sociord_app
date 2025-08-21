import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/common/profile_picture.dart';

class CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final String replyingTo;
  final VoidCallback onSend;
  final VoidCallback onGifTap;
  final FocusNode focusNode;

  const CommentInputBar({
    super.key,
    required this.controller,
    required this.replyingTo,
    required this.onSend,
    required this.onGifTap,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kAppLightGreay,
      padding: const EdgeInsets.only(bottom: 30),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ProfilePicture(
              imageUrl: kProfilePic,
              width: 40,
              height: 40,
              borderRadius: 5,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 80),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SingleChildScrollView(
                  reverse: true,
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText:
                          replyingTo.isEmpty
                              ? 'Your Comment'
                              : 'Replying to @$replyingTo',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    minLines: 1,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            IconButton(
              icon: const Icon(Icons.face, color: kAppBlack),
              onPressed: onGifTap,
            ),
            const SizedBox(width: 5),
            FloatingActionButton(
              shape: const CircleBorder(),
              mini: true,
              backgroundColor: kAppPurple,
              onPressed: onSend,
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
