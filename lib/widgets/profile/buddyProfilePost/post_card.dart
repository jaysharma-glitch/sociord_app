import 'package:flutter/material.dart';
import 'post_model.dart';
import 'post_interaction_bar.dart';
import 'post_media.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final String? userName;
  final String? profileImage;
  final bool showProfile;
  final VoidCallback? onProfileTap;
  final ValueChanged<Post>? onLikeChanged;
  final Function(String)? onMessageSend;
  final VoidCallback? onMoreOptions;
  final bool autoPlay;

  const PostCard({
    super.key,
    required this.post,
    this.userName,
    this.profileImage,
    this.showProfile = true,
    this.onProfileTap,
    this.onLikeChanged,
    this.onMessageSend,
    this.onMoreOptions,
    this.autoPlay = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late Post _post;
  late AnimationController _heartCtrl;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.4,
      upperBound: 1.2,
    );
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  void _likeWithAnimation() {
    if (!_post.liked) {
      _post = _post.copyWith(liked: true, likeCount: _post.likeCount + 1);
      widget.onLikeChanged?.call(_post);
    }
    _heartCtrl.forward(from: 0.4).then((_) => _heartCtrl.reverse());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // media with three dots menu and heart animation
          SizedBox(
            height:
                widget.post.mediaType == MediaType.image
                    ? MediaQuery.of(context).size.width *
                        1.25 // Standard height for images
                    : MediaQuery.of(context).size.width *
                        2.0, // Taller height for videos
            child: Stack(
              children: [
                PostMedia(
                  post: _post,
                  onDoubleTapLike: _likeWithAnimation,
                  autoPlay: widget.autoPlay,
                ),
                // Three dots menu in top right
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap:
                        widget.onMoreOptions ??
                        () {
                          _showMoreOptions(context);
                        },
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Interaction bar
          PostInteractionBar(
            userName: widget.userName,
            profileImage: widget.profileImage,
            caption: _post.caption,
            onProfileTap: widget.onProfileTap,
            onLikeTap: () {
              _likeWithAnimation();
            },
            onMessageSend: widget.onMessageSend,
            showProfile: widget.showProfile,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share'),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle share
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.report),
                  title: const Text('Report'),
                  onTap: () {
                    Navigator.pop(context);
                    // Handle report
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }
}
