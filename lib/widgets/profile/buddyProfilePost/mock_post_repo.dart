import 'post_model.dart';
import 'post_repo.dart';
import 'post_source.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/utils/video_path_constants.dart';

class MockPostRepo implements PostRepo {
  // Mock data - in real app this would come from API
  static final List<Post> _mockPosts = [
    Post(
      id: 'post_1',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      mediaType: MediaType.image,
      mediaUrl: kBuddyUploads[0],
      aspectRatio: 4 / 5,
      caption: 'Amazing sunset today! 🌅',
      liked: false,
      likeCount: 24,
    ),
    Post(
      id: 'post_2',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      mediaType: MediaType.video,
      mediaUrl: VideoPathConstants.getBuddyVideo(0), // 1.mp4
      thumbnailUrl: kBuddyUploads[1],
      aspectRatio: 16 / 9,
      duration: const Duration(minutes: 2, seconds: 15),
      caption: 'Coffee and coding ☕️',
      liked: true,
      likeCount: 156,
    ),
    Post(
      id: 'post_3',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      mediaType: MediaType.image,
      mediaUrl: kBuddyUploads[2],
      aspectRatio: 4 / 5,
      caption: 'Weekend vibes 🎉',
      liked: false,
      likeCount: 89,
    ),
    Post(
      id: 'post_4',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      mediaType: MediaType.video,
      mediaUrl: VideoPathConstants.getBuddyVideo(1), // 2.mp4
      thumbnailUrl: kBuddyUploads[3],
      aspectRatio: 16 / 9,
      duration: const Duration(minutes: 1, seconds: 45),
      caption: 'New adventure begins 🚀',
      liked: false,
      likeCount: 203,
    ),
    Post(
      id: 'post_5',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      mediaType: MediaType.image,
      mediaUrl: kBuddyUploads[4],
      aspectRatio: 4 / 5,
      caption: 'Perfect day for a walk 🚶‍♂️',
      liked: true,
      likeCount: 67,
    ),
    Post(
      id: 'post_6',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      mediaType: MediaType.video,
      mediaUrl: VideoPathConstants.getBuddyVideo(2), // 3.mp4
      thumbnailUrl: kBuddyUploads[5],
      aspectRatio: 16 / 9,
      duration: const Duration(minutes: 1, seconds: 30),
      caption: 'Foodie moment 🍕',
      liked: false,
      likeCount: 342,
    ),
    Post(
      id: 'post_7',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 7)),
      mediaType: MediaType.image,
      mediaUrl: kBuddyUploads[6],
      aspectRatio: 4 / 5,
      caption: 'Creative inspiration ✨',
      liked: false,
      likeCount: 45,
    ),
    Post(
      id: 'post_8',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      mediaType: MediaType.video,
      mediaUrl: VideoPathConstants.getBuddyVideo(3), // 4.mp4
      thumbnailUrl: kBuddyUploads[7],
      aspectRatio: 16 / 9,
      duration: const Duration(minutes: 2, seconds: 30),
      caption: 'Music studio session 🎵',
      liked: true,
      likeCount: 178,
    ),
    Post(
      id: 'post_9',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 9)),
      mediaType: MediaType.video,
      mediaUrl: VideoPathConstants.getBuddyVideo(4), // 5.mp4
      thumbnailUrl: kBuddyUploads[8], // Valid index (0-8)
      aspectRatio: 16 / 9,
      duration: const Duration(minutes: 2, seconds: 15),
      caption: 'Gaming night 🎮',
      liked: false,
      likeCount: 123,
    ),
    Post(
      id: 'post_10',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      mediaType: MediaType.video,
      mediaUrl: VideoPathConstants.getBuddyVideo(5), // 6.mp4
      thumbnailUrl: kBuddyUploads[0], // Cycle back to first image
      aspectRatio: 16 / 9,
      duration: const Duration(minutes: 3, seconds: 45),
      caption: 'Weekend vibes 🎉',
      liked: true,
      likeCount: 89,
    ),
    Post(
      id: 'post_11',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 11)),
      mediaType: MediaType.video,
      mediaUrl: VideoPathConstants.getBuddyVideo(6), // 7.mp4
      thumbnailUrl: kBuddyUploads[1], // Cycle back to second image
      aspectRatio: 16 / 9,
      duration: const Duration(minutes: 2, seconds: 30),
      caption: 'Creative inspiration ✨',
      liked: false,
      likeCount: 45,
    ),
    Post(
      id: 'post_12',
      userId: 'user_1',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      mediaType: MediaType.video,
      mediaUrl: VideoPathConstants.getBuddyVideo(7), // 8.mp4
      thumbnailUrl: kBuddyUploads[2], // Cycle back to third image
      aspectRatio: 16 / 9,
      duration: const Duration(minutes: 4, seconds: 15),
      caption: 'Perfect day for a walk 🚶‍♂️',
      liked: true,
      likeCount: 67,
    ),
  ];

  // Static getter to access all posts
  static List<Post> get allPosts => _mockPosts;

  @override
  Future<List<Post>> fetchUserPosts({
    required String userId,
    required PostSource source,
    int limit = 30,
    DateTime? before,
  }) async {
    // For debugging
    print(
      'MockPostRepo.fetchUserPosts: userId=$userId, source=$source, limit=$limit, before=$before',
    );
    print(
      'MockPostRepo.fetchUserPosts: Total mock posts: ${_mockPosts.length}',
    );

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Filter posts by user and source
    List<Post> filteredPosts =
        _mockPosts.where((post) {
          if (post.userId != userId) {
            print(
              'MockPostRepo.fetchUserPosts: Filtering out post ${post.id} - userId mismatch (${post.userId} != $userId)',
            );
            return false;
          }

          // For now, all posts are uploads. In real app, you'd filter by source
          final matchesSource = source == PostSource.uploads;
          if (!matchesSource) {
            print(
              'MockPostRepo.fetchUserPosts: Filtering out post ${post.id} - source mismatch ($source)',
            );
          }
          return matchesSource;
        }).toList();

    print(
      'MockPostRepo.fetchUserPosts: After filtering: ${filteredPosts.length} posts',
    );

    // Sort by newest first
    filteredPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply pagination if before is provided
    if (before != null) {
      filteredPosts =
          filteredPosts
              .where((post) => post.createdAt.isBefore(before))
              .toList();
      print(
        'MockPostRepo.fetchUserPosts: After pagination: ${filteredPosts.length} posts',
      );
    }

    // Apply limit
    if (filteredPosts.length > limit) {
      filteredPosts = filteredPosts.take(limit).toList();
      print(
        'MockPostRepo.fetchUserPosts: After limit: ${filteredPosts.length} posts',
      );
    }

    print(
      'MockPostRepo.fetchUserPosts: Returning ${filteredPosts.length} posts',
    );
    for (var post in filteredPosts) {
      print('  - ${post.id}: ${post.caption}');
    }

    return filteredPosts;
  }
}
