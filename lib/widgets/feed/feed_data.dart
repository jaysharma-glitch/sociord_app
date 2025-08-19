import 'feed_item.dart';
import 'feed_type.dart';

class FeedData {
  final List<FeedItem> items;
  final String userName;
  final String profileImage;
  final FeedType type;
  final String sectionTitle;

  const FeedData({
    required this.items,
    required this.userName,
    required this.profileImage,
    required this.type,
    required this.sectionTitle,
  });

  factory FeedData.buddy({
    required List<FeedItem> items,
    required String userName,
    required String profileImage,
  }) {
    return FeedData(
      items: items,
      userName: userName,
      profileImage: profileImage,
      type: FeedType.buddy,
      sectionTitle: 'Buddy feed',
    );
  }

  factory FeedData.highlight({
    required List<FeedItem> items,
    required String userName,
    required String profileImage,
  }) {
    return FeedData(
      items: items,
      userName: userName,
      profileImage: profileImage,
      type: FeedType.highlight,
      sectionTitle: 'Highlights',
    );
  }
}
