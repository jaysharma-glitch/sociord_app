import 'post_model.dart';
import 'post_repo.dart';
import 'post_source.dart';
import 'package:sociord/utils/asset_path_constants.dart';

class MockPostRepo implements PostRepo {
  // Mock data - in real app this would come from API
  static final List<Post> _mockPosts = [
    Post(
      id: 'post_1',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      mediaUrl: kBuddyUploads[0],
      caption: 'Amazing sunset today! 🌅',
    ),
    Post(
      id: 'post_2',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      mediaUrl: kBuddyUploads[1],
      caption: 'Coffee and coding ☕️',
    ),
    Post(
      id: 'post_3',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      mediaUrl: kBuddyUploads[2],
      caption: 'Weekend vibes 🎉',
    ),
    Post(
      id: 'post_4',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      mediaUrl: kBuddyUploads[3],
      caption: 'New adventure begins 🚀',
    ),
    Post(
      id: 'post_5',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      mediaUrl: kBuddyUploads[4],
      caption: 'Perfect day for a walk 🚶‍♂️',
    ),
    Post(
      id: 'post_6',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      mediaUrl: kBuddyUploads[5],
      caption: 'Foodie moment 🍕',
    ),
    Post(
      id: 'post_7',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 7)),
      mediaUrl: kBuddyUploads[6],
      caption: 'Creative inspiration ✨',
    ),
    Post(
      id: 'post_8',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      mediaUrl: kBuddyUploads[7],
      caption: 'Music studio session 🎵',
    ),
    Post(
      id: 'post_9',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 9)),
      mediaUrl: kBuddyUploads[8],
      caption: 'Gaming night 🎮',
    ),
  ];

  @override
  Future<List<Post>> fetchUserPosts({
    required String userId,
    required PostSource source,
    int limit = 30,
    DateTime? before,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Filter posts by user and source
    List<Post> filteredPosts =
        _mockPosts.where((post) {
          if (post.userId != userId) return false;

          // For now, all posts are uploads. In real app, you'd filter by source
          return source == PostSource.uploads;
        }).toList();

    // Sort by newest first
    filteredPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply pagination if before is provided
    if (before != null) {
      filteredPosts =
          filteredPosts
              .where((post) => post.createdAt.isBefore(before))
              .toList();
    }

    // Apply limit
    if (filteredPosts.length > limit) {
      filteredPosts = filteredPosts.take(limit).toList();
    }

    return filteredPosts;
  }
}
