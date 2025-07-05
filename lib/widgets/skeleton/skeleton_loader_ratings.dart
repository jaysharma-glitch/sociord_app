import 'package:flutter/material.dart';

class SkeletonLoaderRatings extends StatelessWidget {
  const SkeletonLoaderRatings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      itemBuilder:
          (context, idx) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    width: 22,
                    height: 22,
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 12),
                Container(width: 80, height: 12, color: Colors.grey[300]),
                const SizedBox(width: 8),
                Container(width: 50, height: 10, color: Colors.grey[200]),
                const Spacer(),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
