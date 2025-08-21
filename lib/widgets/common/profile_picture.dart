import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';

class ProfilePicture extends StatelessWidget {
  final String imageUrl;
  final String? userName;
  final String? userHandle;
  final double? width;
  final double? height;
  final double imageSize;
  final double borderRadius;
  final double aspectRatio;
  final VoidCallback? onTap;
  final bool showUserInfo;
  final TextStyle? nameStyle;
  final TextStyle? handleStyle;

  const ProfilePicture({
    super.key,
    required this.imageUrl,
    this.userName,
    this.userHandle,
    this.width,
    this.height,
    this.imageSize = 50,
    this.borderRadius = 5,
    this.aspectRatio = 4 / 5,
    this.onTap,
    this.showUserInfo = false,
    this.nameStyle,
    this.handleStyle,
  });

  @override
  Widget build(BuildContext context) {
    Widget profileImage = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        imageUrl,
        width: width ?? imageSize,
        height: height ?? imageSize,
        fit: BoxFit.cover,
      ),
    );

    // Apply aspect ratio if width and height are not specified
    if (width == null && height == null) {
      profileImage = AspectRatio(aspectRatio: aspectRatio, child: profileImage);
    }

    if (onTap != null) {
      profileImage = GestureDetector(onTap: onTap, child: profileImage);
    }

    if (!showUserInfo) {
      return profileImage;
    }

    return Row(
      children: [
        profileImage,
        if (userName != null || userHandle != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userName != null)
                  Text(
                    userName!,
                    style:
                        nameStyle ??
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: kAppBlack,
                        ),
                  ),
                if (userHandle != null)
                  Text(
                    userHandle!,
                    style:
                        handleStyle ??
                        Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: kAppBlack.withOpacity(0.6),
                        ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
