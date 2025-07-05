import 'package:flutter/material.dart';

class SkeletonLoaderShare extends StatelessWidget {
  const SkeletonLoaderShare({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 9,
      itemBuilder:
          (context, idx) => Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey[300],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(width: 60, height: 10, color: Colors.grey[200]),
            ],
          ),
    );
  }
}
