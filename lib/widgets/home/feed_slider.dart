import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/gradient_text.dart';
import 'package:sociord/widgets/home/buddy_feed_sheet.dart'; // Corrected import for BuddyFeedSheet

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

  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    // Map buddy usernames to their profile images using asset path constants
    final Map<String, String> buddyProfiles = {
      'emma.wave': kBuddy1,
      'oliver_in_focus': kBuddy2,
      'liamdavis': kBuddy3,
      'diya.codes': kBuddy4,
      'noah.the.explorer': kBuddy5,
      'amara.now': kBuddy6,
    };
    // Map buddy usernames to their story images
    final Map<String, String> buddyStories = {
      'emma.wave': kBuddyFeed1,
      'oliver_in_focus': kBuddyFeed2,
      'liamdavis': kBuddyFeed3,
      'diya.codes': kBuddyFeed4,
      'noah.the.explorer': kBuddyFeed5,
      'amara.now': kBuddyFeed6,
    };
    final List<Map<String, String>> buddyFeedBuddies = [
      {'name': 'emma.wave'},
      {'name': 'oliver_in_focus'},
      {'name': 'liamdavis'},
      {'name': 'diya.codes'},
      {'name': 'noah.the.explorer'},
      {'name': 'amara.now'},
    ];
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                });
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: GradientText(
                      text: 'Buddy feed',
                      gradient: const LinearGradient(
                        colors: [kAppPurple, kAppOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      style: Theme.of(context).textTheme.headlineSmall!
                          .copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 5),
                  AnimatedRotation(
                    turns: isExpanded ? 0.0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.expand_less,
                      color: Colors.deepPurple,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child:
                  isExpanded
                      ? SizedBox(
                        height: 155,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: buddyFeedBuddies.length,
                          itemBuilder: (context, index) {
                            final name = buddyFeedBuddies[index]['name']!;
                            final profileImage = buddyProfiles[name] ?? '';
                            final storyImage = buddyStories[name] ?? '';
                            return _buildBuddyItem(
                              profileImage,
                              name,
                              index,
                              storyImage,
                            );
                          },
                        ),
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuddyItem(
    String profileImage,
    String name,
    int index,
    String storyImage,
  ) {
    return Padding(
      padding:
          index == 0
              ? const EdgeInsets.only(left: 12.0, right: 3)
              : const EdgeInsets.symmetric(horizontal: 2.0),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder:
                (context) => BuddyFeedSheet(
                  imagePath: storyImage,
                  username: name,
                  profileImage: profileImage,
                  caption: 'Sample caption for $name',
                ),
          );
        },
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 113,
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
                Container(
                  padding: const EdgeInsets.all(2.5),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 110,
                      height: 130,
                      child: Image.asset(profileImage, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 0),
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: kAppBlack),
            ),
          ],
        ),
      ),
    );
  }
}
