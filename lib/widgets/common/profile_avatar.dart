import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  final double? borderWidth;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool showBorder;

  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    this.size = 40,
    this.borderWidth = 2,
    this.borderColor = kAppPurple,
    this.onTap,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Image.asset(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );

    if (showBorder && borderColor != null && borderWidth != null) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor!, width: borderWidth!),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Image.asset(
            imageUrl,
            width: size - (borderWidth! * 2),
            height: size - (borderWidth! * 2),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    if (onTap != null) {
      avatar = GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }
}
