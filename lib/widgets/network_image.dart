import 'package:flutter/material.dart';
import 'package:sociord/utils/app_constants.dart';

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: isNetworkImage
          ? Image.network(
              width: MediaQuery.of(context).size.width * width,
              url!,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 100,
                  width: 80,
                  child: const Center(
                    child: SizedBox(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kAppPurple,
                          backgroundColor: Colors.transparent,
                        )),
                  ),
                );
              },
              // errorBuilder: (context, error, stackTrace) {
              //   return Image.asset('assets/fallback_image.png'); // Fallback image
              // },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: kAppRed, size: 50),
                      const SizedBox(height: 8),
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
              width: MediaQuery.of(context).size.width * width,
              url!,
            ),
    );
  }
}
