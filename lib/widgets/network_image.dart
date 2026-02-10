import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sociord/constants/color.dart';

class CustomeNetworkImage extends StatelessWidget {
  final String? url;
  final double width;
  final double borderRadius;
  const CustomeNetworkImage(
      {super.key,
      required this.url,
      this.width = 0.25,
      this.borderRadius = 5.0});

  @override
  Widget build(BuildContext context) {
    bool isNetworkImage = url!.startsWith('http') || url!.startsWith('https');
    final imageWidth = MediaQuery.of(context).size.width * width;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: isNetworkImage
          ? Image.network(
              url!,
              width: imageWidth,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                // Shimmer skeleton while the image is loading
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: imageWidth,
                    height: 150.0,
                    color: Colors.white,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: kAppRed, size: 50),
                      SizedBox(height: 8),
                      Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            )
          : Image.asset(
              url!,
              width: imageWidth,
              fit: BoxFit.cover,
            ),
    );
  }
}
