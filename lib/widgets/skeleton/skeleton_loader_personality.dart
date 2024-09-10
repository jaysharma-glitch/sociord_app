import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoaderPersonality extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example of a skeleton loader for a list of items
            // Container(
            //   width: 150.0,
            //   height: 20.0,
            //   color: Colors.white,
            // ),
            // SizedBox(height: 10),
            // Container(
            //   width: 100.0,
            //   height: 20.0,
            //   color: Colors.white,
            // ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: 150.0,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 50.0,
                      height: 10.0,
                      color: Colors.white,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: 150.0,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 50.0,
                      height: 10.0,
                      color: Colors.white,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: 150.0,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 50.0,
                      height: 10.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: 150.0,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 50.0,
                      height: 10.0,
                      color: Colors.white,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: 150.0,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 50.0,
                      height: 10.0,
                      color: Colors.white,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: 150.0,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 50.0,
                      height: 10.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
