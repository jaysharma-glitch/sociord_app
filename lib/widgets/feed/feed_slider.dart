import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/constants/text_styles.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/gradient_text.dart';
import 'package:sociord/widgets/feed/feed_data.dart';
import 'package:sociord/widgets/feed/feed_item.dart';
import 'package:sociord/widgets/feed/feed_sheet.dart';
import 'package:sociord/widgets/feed/feed_type.dart';

// Enum to distinguish between different types of feed sliders
// This helps with better organization and potential future customization
enum FeedSliderType {
  buddyFeed, // Used for buddy feed on home page
  highlight, // Used for highlights on profile pages
}

class FeedSlider extends StatefulWidget {
  final FeedData feedData;
  final Function(FeedItem item, int index)? onItemTap;
  final bool showHeader; // Add parameter to control header visibility
  final FeedSliderType sliderType; // Add parameter to distinguish slider type

  /// Creates a FeedSlider widget
  ///
  /// [feedData] - The data to display in the slider
  /// [onItemTap] - Optional callback when an item is tapped
  /// [showHeader] - Whether to show the expandable header (default: true)
  /// [sliderType] - The type of slider (buddyFeed or highlight) for better organization (default: buddyFeed)
  const FeedSlider({
    super.key,
    required this.feedData,
    this.onItemTap,
    this.showHeader = true, // Default to true for backward compatibility
    this.sliderType =
        FeedSliderType
            .buddyFeed, // Default to buddyFeed for backward compatibility
  });

  @override
  State<FeedSlider> createState() => _FeedSliderState();
}

class _FeedSliderState extends State<FeedSlider> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Only show header if showHeader is true
          if (widget.showHeader) ...[
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
                      text: widget.feedData.sectionTitle,
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
          ],

          // Feed items section
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child:
                isExpanded
                    ? SizedBox(
                      height:
                          widget.sliderType == FeedSliderType.buddyFeed
                              ? 150
                              : 155,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding:
                            widget.sliderType == FeedSliderType.buddyFeed
                                ? const EdgeInsets.symmetric(horizontal: 16)
                                : const EdgeInsets.only(top: 5),
                        itemCount: widget.feedData.items.length,
                        itemBuilder: (context, index) {
                          return _buildFeedItem(
                            widget.feedData.items[index],
                            index,
                          );
                        },
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedItem(FeedItem item, int index) {
    return Container(
      padding:
          index == 0 && widget.sliderType == FeedSliderType.buddyFeed
              ? const EdgeInsets.only(left: 12.0, right: 3)
              : index == 0 && widget.sliderType == FeedSliderType.highlight
              ? const EdgeInsets.only(left: 0.0, right: 3)
              : const EdgeInsets.symmetric(horizontal: 2.0),
      margin:
          index == 0 && widget.sliderType == FeedSliderType.highlight
              ? const EdgeInsets.only(left: 15)
              : const EdgeInsets.only(left: 0),
      child: GestureDetector(
        onTap: () {
          if (widget.onItemTap != null) {
            // Use custom callback if provided
            widget.onItemTap!(item, index);
          } else {
            // Default navigation behavior
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) => FeedSheet(
                      feedData: widget.feedData,
                      initialIndex: index,
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
          }
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
                  child: Hero(
                    tag: 'feed_${widget.feedData.type}_${index}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 110,
                        height: 130,
                        child: Image.asset(
                          widget.feedData.type == FeedType.buddy
                              ? (item.profileImage ?? item.imagePath)
                              : item.imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 0),
            Text(
              item.title,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: kAppBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
