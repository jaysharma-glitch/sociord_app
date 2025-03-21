import 'package:flutter/material.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/gradient_text.dart';

class FeedSlider extends StatefulWidget {
  const FeedSlider({super.key});

  @override
  State<FeedSlider> createState() => _FeedSliderState();
}

class _FeedSliderState extends State<FeedSlider> {
  final List<Map<String, String>> buddies = [
    {'image': kBuddy1, 'name': 'emma.wave'},
    {'image': kBuddy2, 'name': 'oliver_in_focus'},
    {'image': kBuddy3, 'name': 'liamdavis'},
    {'image': kBuddy4, 'name': 'diya.codes'},
    {'image': kBuddy5, 'name': 'noah.the.explorer'},
    {'image': kBuddy6, 'name': 'amara.now'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with Collapse Icon
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: GradientText(
                  text: 'Buddy feed',
                  gradient: const LinearGradient(
                    colors: [kAppPurple, kAppOrange],
                    begin: Alignment.topLeft, // Gradient starts from top-left
                    end: Alignment.bottomRight, // Gradient ends at bottom-right
                  ),
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 5),
            Icon(Icons.expand_less, color: Colors.deepPurple, size: 18),
          ],
        ),
        const SizedBox(height: 5),

        // Horizontal Scrolling List
        SizedBox(
          height: 155,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: buddies.length,
            itemBuilder: (context, index) {
              return _buildBuddyItem(
                  buddies[index]['image']!, buddies[index]['name']!, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBuddyItem(String imagePath, String name, int index) {
    return Padding(
      padding: index == 0
          ? const EdgeInsets.only(left: 12.0, right: 3)
          : const EdgeInsets.symmetric(horizontal: 2.0),
      child: Column(
        children: [
          // Stack for Layering Gradient Border & Image
          Stack(
            alignment: Alignment.center,
            children: [
              // Gradient Border Layer
              Container(
                width: 113, // Slightly larger than image for border effect
                height: 133,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.orange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Image Layer with White Background Border
              Container(
                padding: const EdgeInsets.all(2.5), // Thickness of border

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    width: 110,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 0),

          // Username
          Text(
            name,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: kAppBlack,
                ),
          ),
        ],
      ),
    );
  }
}
