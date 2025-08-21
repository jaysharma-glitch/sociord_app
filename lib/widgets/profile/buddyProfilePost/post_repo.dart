import 'post_model.dart';
import 'post_source.dart';

abstract class PostRepo {
  /// Returns posts for a user, newest → oldest.
  Future<List<Post>> fetchUserPosts({
    required String userId,
    required PostSource source,
    int limit = 30,
    DateTime? before, // for pagination: fetch older than this createdAt
  });
}
