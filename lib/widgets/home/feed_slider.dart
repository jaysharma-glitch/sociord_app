import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/feed/feed_data.dart';
import 'package:sociord/widgets/feed/feed_item.dart';
import 'package:sociord/widgets/feed/feed_slider.dart' as GenericFeedSlider;
import 'package:sociord/widgets/feed/feed_type.dart';
import 'package:sociord/widgets/feed/feed_sheet.dart'; // Added import for FeedSheet

class FeedSlider extends StatefulWidget {
  const FeedSlider({super.key});

  @override
  State<FeedSlider> createState() => _FeedSliderState();
}

class _FeedSliderState extends State<FeedSlider> {
  @override
  Widget build(BuildContext context) {
    // Create buddy feed data using the new generic system
    final buddyFeedData = FeedData.buddy(
      items: _createBuddyFeedItems(),
      userName: 'emma.wave', // Default user for buddy feed
      profileImage: kBuddy1,
    );

    return GenericFeedSlider.FeedSlider(
      feedData: buddyFeedData,
      sliderType:
          GenericFeedSlider
              .FeedSliderType
              .buddyFeed, // Specify this is a buddy feed slider
      onItemTap: (FeedItem item, int index) {
        // Generate all posts for ALL users (not just the selected user)
        // This allows navigation between different users in the FeedSheet
        List<FeedItem> allUsersPosts = [];

        final List<String> allUsernames = [
          'emma.wave',
          'oliver_in_focus',
          'liamdavis',
          'diya.codes',
          'noah.the.explorer',
          'amara.now',
        ];

        for (String username in allUsernames) {
          final userPosts = getAllPostsForUser(username);
          allUsersPosts.addAll(userPosts);
        }

        print('DEBUG: Total posts for all users: ${allUsersPosts.length}');
        print('DEBUG: Selected user: ${item.userName}');

        final userFeedData = FeedData.buddy(
          items: allUsersPosts,
          userName: item.userName ?? '',
          profileImage: item.profileImage ?? '',
        );

        // Navigate with custom transition to preserve hero animation
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => FeedSheet(
                  feedData: userFeedData,
                  initialIndex: _getInitialIndexForUser(
                    item.userName ?? '',
                    allUsersPosts,
                  ),
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

  List<FeedItem> _createBuddyFeedItems() {
    // Map buddy usernames to their profile images using asset path constants
    final Map<String, String> buddyProfiles = {
      'emma.wave': kBuddy1,
      'oliver_in_focus': kBuddy2,
      'liamdavis': kBuddy3,
      'diya.codes': kBuddy4,
      'noah.the.explorer': kBuddy5,
      'amara.now': kBuddy6,
    };

    // Map buddy usernames to their story images (one per user for slider)
    final Map<String, String> buddyStories = {
      'emma.wave': kBuddyFeed1,
      'oliver_in_focus': kBuddyFeed2,
      'liamdavis': kBuddyFeed3,
      'diya.codes': kBuddyFeed4,
      'noah.the.explorer': kBuddyFeed5,
      'amara.now': kBuddyFeed1,
    };

    final List<String> buddyUsernames = [
      'emma.wave',
      'oliver_in_focus',
      'liamdavis',
      'diya.codes',
      'noah.the.explorer',
      'amara.now',
    ];

    // Create only ONE item per buddy (one entry per user in slider)
    List<FeedItem> allItems = [];

    for (String username in buddyUsernames) {
      final profileImage = buddyProfiles[username] ?? '';
      final storyImage = buddyStories[username] ?? '';

      // Create only ONE FeedItem per user for the slider
      // The actual posts will be generated in the FeedSheet when this user is selected
      allItems.add(
        FeedItem(
          imagePath: storyImage,
          title: username,
          caption: _getCaptionForUser(username),
          profileImage: profileImage,
          userName: username,
          isVideo: username == 'noah.the.explorer', // Only noah has video
          duration: username == 'noah.the.explorer' ? 25 : 15,
        ),
      );
    }

    return allItems;
  }

  String _getCaptionForUser(String username) {
    switch (username) {
      case 'emma.wave':
        return 'Our view today';
      case 'oliver_in_focus':
        return 'Celebrated Holi for the first time!';
      case 'liamdavis':
        return 'Paris❤️❤️❤️';
      case 'diya.codes':
        return 'Coding session today';
      case 'noah.the.explorer':
        return 'Exploring the mountains!';
      case 'amara.now':
        return 'Sample caption for amara.now';
      default:
        return 'Sample caption for $username';
    }
  }

  // Static method to generate all posts for a specific user
  static List<FeedItem> getAllPostsForUser(String username) {
    final Map<String, String> buddyProfiles = {
      'emma.wave': kBuddy1,
      'oliver_in_focus': kBuddy2,
      'liamdavis': kBuddy3,
      'diya.codes': kBuddy4,
      'noah.the.explorer': kBuddy5,
      'amara.now': kBuddy6,
    };

    final profileImage = buddyProfiles[username] ?? '';

    switch (username) {
      case 'emma.wave':
        return [
          FeedItem(
            imagePath: kBuddyFeed1,
            title: username,
            caption: 'Our view today',
            profileImage: profileImage,
            userName: username,
          ),
        ];

      case 'oliver_in_focus':
        return [
          FeedItem(
            imagePath: kBuddyFeed2,
            title: username,
            caption: 'Celebrated Holi for the first time!',
            profileImage: profileImage,
            userName: username,
          ),
          FeedItem(
            imagePath: kBuddyFeed3,
            title: username,
            caption: 'The colours were so beautiful',
            profileImage: profileImage,
            userName: username,
          ),
        ];

      case 'liamdavis':
        return [
          FeedItem(
            imagePath: kBuddyFeed3,
            title: username,
            caption: 'Paris❤️❤️❤️',
            profileImage: profileImage,
            userName: username,
          ),
          FeedItem(
            imagePath: kBuddyFeed5,
            title: username,
            caption: 'More Paris adventures',
            profileImage: profileImage,
            userName: username,
          ),
        ];

      case 'diya.codes':
        return [
          FeedItem(
            imagePath: kBuddyFeed4,
            title: username,
            caption: 'Coding session today',
            profileImage: profileImage,
            userName: username,
          ),
        ];

      case 'noah.the.explorer':
        return [
          FeedItem(
            imagePath: kBuddyFeed5,
            title: username,
            caption: 'Exploring the mountains!',
            profileImage: profileImage,
            userName: username,
            isVideo: true,
            duration: 25,
          ),
        ];

      case 'amara.now':
        return [
          FeedItem(
            imagePath: kBuddyFeed1,
            title: username,
            caption: 'Sample caption for amara.now',
            profileImage: profileImage,
            userName: username,
          ),
        ];

      default:
        return [
          FeedItem(
            imagePath: kBuddyFeed1,
            title: username,
            caption: 'Sample caption for $username',
            profileImage: profileImage,
            userName: username,
          ),
        ];
    }
  }

  // Static method to generate all posts for a specific highlight
  static List<FeedItem> getAllPostsForHighlight(
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

  // Helper to get the initial index for a specific user in the FeedSheet
  static int _getInitialIndexForUser(String username, List<FeedItem> allPosts) {
    int index = 0;
    for (int i = 0; i < allPosts.length; i++) {
      if (allPosts[i].userName == username) {
        index = i;
        break;
      }
    }
    return index;
  }
}
