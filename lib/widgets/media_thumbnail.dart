import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/provider/media_selection_provider.dart';
import 'package:sociord/constants/color.dart';

class MediaThumbnail extends ConsumerWidget {
  final AssetEntity asset;
  final VoidCallback? onTap;
  final double size;

  const MediaThumbnail({
    super.key,
    required this.asset,
    this.onTap,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = ref
        .watch(mediaSelectionNotifierProvider.notifier)
        .isSelected(asset);
    final selectionIndex = ref
        .watch(mediaSelectionNotifierProvider)
        .indexWhere((item) => item.id == asset.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: kAppPurple, width: 2) : null,
        ),
        child: Stack(
          children: [
            // Thumbnail image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: FutureBuilder<Uint8List?>(
                future: asset.thumbnailDataWithSize(
                  const ThumbnailSize.square(200),
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Image.memory(
                      snapshot.data!,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                    );
                  }
                  return Container(
                    width: size,
                    height: size,
                    color: kAppLightGreay,
                    child: const Icon(
                      Icons.image_not_supported,
                      color: kAppLightBlack,
                    ),
                  );
                },
              ),
            ),

            // Selection overlay
            if (isSelected)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: kAppPurple.withValues(alpha: 0.3),
                ),
              ),

            // Selection indicator
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: kAppPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${selectionIndex + 1}',
                      style: const TextStyle(
                        color: kAppWhite,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

            // Video duration indicator
            if (asset.type == AssetType.video)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatDuration(asset.duration),
                    style: const TextStyle(
                      color: kAppWhite,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int durationInSeconds) {
    final duration = Duration(seconds: durationInSeconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
