import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoaderPersonality extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final padding = 20.0;
          final maxWidth = constraints.maxWidth.isInfinite
              ? MediaQuery.of(context).size.width
              : constraints.maxWidth;
          final availableWidth = maxWidth - (padding * 2);
          final itemWidth = (availableWidth - 20) / 3;
          final textBarWidth = itemWidth.clamp(0.0, 50.0);
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _skeletonColumn(itemWidth, 150.0, textBarWidth, 10.0),
                    _skeletonColumn(itemWidth, 150.0, textBarWidth, 10.0),
                    _skeletonColumn(itemWidth, 150.0, textBarWidth, 10.0),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _skeletonColumn(itemWidth, 150.0, textBarWidth, 10.0),
                    _skeletonColumn(itemWidth, 150.0, textBarWidth, 10.0),
                    _skeletonColumn(itemWidth, 150.0, textBarWidth, 10.0),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _skeletonColumn(
    double imageWidth,
    double imageHeight,
    double textWidth,
    double textHeight,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: imageWidth,
          height: imageHeight,
          color: Colors.white,
        ),
        SizedBox(height: 10),
        Container(
          width: textWidth,
          height: textHeight,
          color: Colors.white,
        ),
      ],
    );
  }
}
