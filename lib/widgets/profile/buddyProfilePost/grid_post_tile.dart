import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'post_model.dart';

class GridPostTile extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;

  const GridPostTile({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: InkWell(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Check if it's a local asset or network URL
              post.mediaUrl.startsWith('assets/')
                  ? Image.asset(
                      post.mediaType == MediaType.image
                          ? post.mediaUrl
                          : (post.thumbnailUrl ?? post.mediaUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl:
                          post.mediaType == MediaType.image
                              ? post.mediaUrl
                              : (post.thumbnailUrl ?? post.mediaUrl),
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget:
                          (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    ),
              if (post.mediaType == MediaType.video) ...[
                const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    size: 34,
                    color: Colors.white70,
                  ),
                ),
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: _Badge(
                    child: Text(
                      _formatDuration(post.duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDuration(Duration? d) {
    if (d == null) return '';
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return m > 0
        ? '$m:${s.toString().padLeft(2, '0')}'
        : '0:${s.toString().padLeft(2, '0')}';
  }
}

class _Badge extends StatelessWidget {
  final Widget child;
  const _Badge({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(6),
    ),
    child: child,
  );
}
