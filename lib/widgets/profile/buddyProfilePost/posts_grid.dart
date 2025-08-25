import 'package:flutter/material.dart';
import 'post_model.dart';
import 'grid_post_tile.dart';

class PostsGrid extends StatelessWidget {
  final List<Post> posts;
  final Function(Post) onPostTap;

  const PostsGrid({super.key, required this.posts, required this.onPostTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return GridPostTile(post: post, onTap: () => onPostTap(post));
      },
    );
  }
}
