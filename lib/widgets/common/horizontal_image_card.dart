import 'package:flutter/material.dart';

class HorizontalImageCard extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Widget? child;

  const HorizontalImageCard({
    super.key,
    required this.imageUrl,
    this.width = 120,
    this.height = 160,
    this.borderRadius = 5,
    this.margin,
    this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin ?? const EdgeInsets.only(right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  image: DecorationImage(
                    image: AssetImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Optional child content (for clips with title, stats, etc.)
            if (child != null) ...[const SizedBox(height: 4), child!],
          ],
        ),
      ),
    );
  }
}
