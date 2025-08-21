import 'package:flutter/material.dart';

class PostImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final double aspectRatio;
  final double borderRadius;
  final BoxFit fit;
  final VoidCallback? onTap;
  final VoidCallback? onMoreOptions;
  final bool showMoreOptions;
  final Widget? overlay;

  const PostImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.aspectRatio = 4 / 5,
    this.borderRadius = 5,
    this.fit = BoxFit.cover,
    this.onTap,
    this.onMoreOptions,
    this.showMoreOptions = false,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(imageUrl, width: width, height: height, fit: fit),
    );

    if (width == null && height == null) {
      image = AspectRatio(aspectRatio: aspectRatio, child: image);
    }

    if (onTap != null) {
      image = GestureDetector(onTap: onTap, child: image);
    }

    if (showMoreOptions || overlay != null) {
      image = Stack(
        children: [
          image,
          if (showMoreOptions)
            Positioned(
              top: 12,
              right: 12,
              child: GestureDetector(
                onTap:
                    onMoreOptions ??
                    () {
                      _showMoreOptions(context);
                    },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          if (overlay != null) overlay!,
        ],
      );
    }

    return image;
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
