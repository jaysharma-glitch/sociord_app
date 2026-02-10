import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Skeleton loader for the profile hero area (shimmer/glimmer effect).
class SkeletonLoaderProfile extends StatelessWidget {
  const SkeletonLoaderProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // Banner placeholder
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(height: 16),
            // Hero row: profile pic + details
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 140,
                          height: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 100,
                          height: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 120,
                          height: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        // Sync contacts placeholder
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const Spacer(),
                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _statPlaceholder(),
                            _statPlaceholder(),
                            _statPlaceholder(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Handle + switch
            Container(
              width: 100,
              height: 12,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Container(
              width: 120,
              height: 12,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            // Buttons
            Row(
              children: [
                Container(
                  width: 100,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 130,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _statPlaceholder() {
    return Column(
      children: [
        Container(
          width: 28,
          height: 16,
          color: Colors.white,
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 10,
          color: Colors.white,
        ),
      ],
    );
  }
}
