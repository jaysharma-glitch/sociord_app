import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/widgets/common/profile_picture.dart';

class PostInteractionBar extends StatefulWidget {
  final String? userName;
  final String? profileImage;
  final String? caption;
  final String? title;
  final bool isHighlight;
  final bool showProfile; // New parameter to control profile visibility
  final VoidCallback? onProfileTap;
  final VoidCallback? onLikeTap;
  final Function(String)? onMessageSend;

  const PostInteractionBar({
    super.key,
    this.userName,
    this.profileImage,
    this.caption,
    this.title,
    this.isHighlight = false,
    this.showProfile = true, // Default to true for backward compatibility
    this.onProfileTap,
    this.onLikeTap,
    this.onMessageSend,
  });

  @override
  State<PostInteractionBar> createState() => _PostInteractionBarState();
}

class _PostInteractionBarState extends State<PostInteractionBar> {
  final TextEditingController _messageController = TextEditingController();
  bool _isLiked = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kAppWhite,
      padding:
          widget.showProfile
              ? const EdgeInsets.only(right: 16, left: 16, bottom: 10)
              : const EdgeInsets.only(top: 10, right: 16, left: 16, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showProfile) ...[
            Row(
              children: [
                if (widget.profileImage != null) ...[
                  ProfilePicture(
                    imageUrl: widget.profileImage!,
                    imageSize: 35,
                    borderRadius: 5,
                    onTap: widget.onProfileTap,
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onProfileTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.userName != null) ...[
                          Text(
                            widget.userName!,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineLarge!.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ],
                        if (widget.isHighlight && widget.title != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.title!,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineLarge!.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: kAppPurple,
                            ),
                          ),
                        ],
                        if (widget.caption != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.caption!,
                            style: Theme.of(
                              context,
                            ).textTheme.headlineLarge!.copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isLiked = !_isLiked;
                    });
                    widget.onLikeTap?.call();
                  },
                  child: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? kAppPurple : kAppBlack,
                    size: 26,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ] else ...[
            // When profile is hidden, show caption and like button in a row
            Row(
              children: [
                if (widget.caption != null) ...[
                  Expanded(
                    child: Text(
                      widget.caption!,
                      style: Theme.of(context).textTheme.headlineLarge!
                          .copyWith(fontWeight: FontWeight.w400, fontSize: 15),
                    ),
                  ),
                ],
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isLiked = !_isLiked;
                    });
                    widget.onLikeTap?.call();
                  },
                  child: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? kAppPurple : kAppBlack,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
          ],
          Row(
            children: [
              Expanded(
                child: Container(
                  constraints:
                      widget.showProfile
                          ? const BoxConstraints(minHeight: 60, maxHeight: 120)
                          : const BoxConstraints(minHeight: 25, maxHeight: 60),
                  decoration: BoxDecoration(
                    color: kAppWhite,
                    borderRadius:
                        widget.showProfile
                            ? BorderRadius.circular(5)
                            : BorderRadius.circular(100),
                    border: Border.all(color: kBorderGreay, width: 1),
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: kAppBlack,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Send a message',
                      hintStyle: Theme.of(
                        context,
                      ).textTheme.bodyMedium!.copyWith(
                        color: kAppBlack.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                    maxLines: null,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    onSubmitted: (_) {
                      if (_messageController.text.isNotEmpty) {
                        widget.onMessageSend?.call(_messageController.text);
                        _messageController.clear();
                        setState(() {});
                      }
                    },
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              if (_messageController.text.isNotEmpty) ...[
                const SizedBox(width: 10),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kAppPurple,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () {
                      widget.onMessageSend?.call(_messageController.text);
                      _messageController.clear();
                      setState(() {});
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
