import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoaderPets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const padding = 20.0;
          const spacing = 30.0;
          final maxWidth = constraints.maxWidth.isInfinite
              ? MediaQuery.of(context).size.width
              : constraints.maxWidth;
          final availableWidth = maxWidth - (padding * 2);
          final imageWidth = ((availableWidth - spacing) * 0.35)
              .clamp(60.0, 120.0);
          final textAreaWidth = availableWidth - imageWidth - spacing;
          final line1Width = textAreaWidth.clamp(50.0, 70.0);
          final line2Width = textAreaWidth.clamp(80.0, 150.0);
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: imageWidth,
                      height: 150.0,
                      color: Colors.white,
                    ),
                    SizedBox(width: spacing),
                    SizedBox(
                      width: textAreaWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: line1Width,
                            height: 12.0,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: line2Width,
                            height: 10.0,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: imageWidth,
                      height: 150.0,
                      color: Colors.white,
                    ),
                    SizedBox(width: spacing),
                    SizedBox(
                      width: textAreaWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: line1Width,
                            height: 12.0,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: line2Width,
                            height: 10.0,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
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
}
