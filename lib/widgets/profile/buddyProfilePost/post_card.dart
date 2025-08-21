import 'package:flutter/material.dart';
import 'post_model.dart';
import 'post_interaction_bar.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final String? userName;
  final String? profileImage;
  final bool showProfile; // New parameter
  final VoidCallback? onProfileTap;
  final VoidCallback? onLikeTap;
  final Function(String)? onMessageSend;
  final VoidCallback? onMoreOptions;

  const PostCard({
    super.key,
    required this.post,
    this.userName,
    this.profileImage,
    this.showProfile = true, // Default to true for backward compatibility
    this.onProfileTap,
    this.onLikeTap,
    this.onMessageSend,
    this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // media with three dots menu
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 4 / 5,
              child: Image.asset(post.mediaUrl, fit: BoxFit.cover),
            ),
            // Three dots menu in top right
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap:
                    onMoreOptions ??
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

        // Interaction bar
        PostInteractionBar(
          userName: userName,
          profileImage: profileImage,
          caption: post.caption,
          onProfileTap: onProfileTap,
          onLikeTap: onLikeTap,
          onMessageSend: onMessageSend,
          showProfile: showProfile, // Pass the new parameter
        ),
        const SizedBox(height: 20),
      ],
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
