import 'package:flutter/material.dart';

class SkeletonLoaderComments extends StatelessWidget {
  const SkeletonLoaderComments({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder:
          (context, idx) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    width: 32,
                    height: 32,
                    color: Colors.grey[300],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 10,
                        width: 120,
                        color: Colors.grey[200],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
