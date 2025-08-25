import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/feed/feed_data.dart';
import 'package:sociord/widgets/feed/feed_item.dart';
import 'package:sociord/widgets/feed/feed_slider.dart';
import 'package:sociord/widgets/feed/feed_type.dart';
import 'package:sociord/widgets/feed/feed_sheet.dart';

class ProfileHighlight extends StatelessWidget {
  final bool isExpanded;
  final String profileType;
  final VoidCallback onToggle;
  final String? userName;
  final bool hasHighlightData;
  final bool isOwnProfile;
  final List<String>? highlightImages;
  final List<String>? highlightNames;
  final String? profileImage;

  const ProfileHighlight({
    super.key,
    required this.isExpanded,
    required this.profileType,
    required this.onToggle,
    this.userName,
    this.hasHighlightData = true,
    this.isOwnProfile = true,
    this.highlightImages,
    this.highlightNames,
    this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show the section at all if no highlight data is available
    if (!hasHighlightData) {
      return const SizedBox.shrink();
    }

    final isCreator = profileType == 'Creator';
    final displayName = userName ?? 'Arjun';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: GestureDetector(
            onTap: onToggle,
            child: Row(
              children: [
                Text(
                  isCreator
                      ? '${displayName} Showcase'
                      : '${displayName} Highlights',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontSize: 15,
                    color: kAppPurple,
                  ),
                ),
                const SizedBox(width: 5),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 100),
                  turns: isExpanded ? 0.5 : 0,
                  child: Image.asset(kChevronDownPurple),
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isExpanded ? null : 0,
          child:
              isExpanded
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Only show the description text for own profile
                      if (isOwnProfile) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            isCreator
                                ? 'Highlight your key projects and brand collaborations right here'
                                : 'Capture your life\'s highlights and relive your best moments.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      // Show highlights slider if we have highlight data
                      if (highlightImages != null &&
                          highlightImages!.isNotEmpty) ...[
                        _buildHighlightsSlider(context, displayName),
                      ] else ...[
                        // Show add highlight placeholder if no highlights
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Container(
                            width: 80,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add,
                                  size: 35,
                                  color: kAppPurple,
                                ),
                                Center(
                                  child: Text(
                                    isCreator
                                        ? 'Promoted a Brand? Share it here'
                                        : 'Got Married? \nShare the memory',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall!.copyWith(
                                      fontSize: 9,
                                      color: kAppPurple,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  )
                  : null,
        ),
      ],
    );
  }

  Widget _buildHighlightsSlider(BuildContext context, String displayName) {
    // Create highlight feed data using the new generic system
    final highlightFeedData = FeedData.highlight(
      items: _createHighlightItems(displayName),
      userName: displayName,
      profileImage: profileImage ?? '',
    );

    return FeedSlider(
      feedData: highlightFeedData,
      showHeader: false, // Hide header on buddy profile
      sliderType:
          FeedSliderType.highlight, // Specify this is a highlight slider
      onItemTap: (FeedItem item, int index) {
        // Pass all highlights to the FeedSheet so users can navigate between them
        // Each highlight will be treated as a separate "user" with its own posts
        final allHighlights = _createHighlightItems(displayName);
        final highlightFeedData = FeedData.highlight(
          items: allHighlights, // All highlights for navigation
          userName: displayName,
          profileImage: profileImage ?? '',
        );

        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => FeedSheet(
                  feedData: highlightFeedData,
                  initialIndex: index, // Start at the tapped highlight
                ),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return child; // No transition - let hero animation handle it
            },
            opaque: false,
            barrierColor: Colors.black,
          ),
        );
      },
    );
  }

  List<FeedItem> _createHighlightItems(String displayName) {
    if (highlightImages == null || highlightImages!.isEmpty) {
      return [];
    }

    // Create one item per highlight (each highlight has one image)
    return highlightImages!.asMap().entries.map((entry) {
      final index = entry.key;
      final imagePath = entry.value;
      final highlightName =
          index < (highlightNames?.length ?? 0)
              ? highlightNames![index]
              : 'Highlight ${index + 1}';

      return FeedItem(
        imagePath: imagePath,
        title: highlightName,
        caption: 'Sample caption for $highlightName',
      );
    }).toList();
  }

  List<FeedItem> _generateAllPostsForHighlight(
    String highlightName,
    List<String> highlightImages,
    List<String> highlightNames,
  ) {
    return highlightImages.asMap().entries.map((entry) {
      final index = entry.key;
      final imagePath = entry.value;
      final name =
          index < highlightNames.length
              ? highlightNames[index]
              : 'Highlight ${index + 1}';

      return FeedItem(
        imagePath: imagePath,
        title: name,
        caption: 'Sample caption for $name',
      );
    }).toList();
  }
}
