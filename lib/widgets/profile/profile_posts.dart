import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/widgets/profile/buddyProfilePost/post_reader_page.dart';
import 'package:sociord/widgets/profile/buddyProfilePost/post_source.dart';
import 'package:sociord/widgets/profile/buddyProfilePost/grid_post_tile.dart';
import 'package:sociord/widgets/profile/buddyProfilePost/mock_post_repo.dart';

enum UserType { explorer, creator }

enum ProfileViewType { own, other }

// PostsTabsBar - renders only the TabBar UI (no TabBarView)
class PostsTabsBar extends StatelessWidget {
  final String profileType;
  final UserType? userType;
  final ProfileViewType? viewType;

  const PostsTabsBar({
    super.key,
    required this.profileType,
    this.userType,
    this.viewType,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCreator = profileType == 'Creator';
    final tabTitles =
        isCreator
            ? const ['Quickies', 'Clips', 'Collections']
            : const ['Uploads', 'Tagged'];

    return TabBar(
      dividerHeight: 0,
      labelColor: kAppBlack,
      unselectedLabelColor: kAppBlack,
      labelStyle: Theme.of(
        context,
      ).textTheme.headlineSmall!.copyWith(fontSize: 12),
      indicatorSize: TabBarIndicatorSize.tab,
      indicator: const UnderlineTabIndicator(
        borderSide: BorderSide(width: 4, color: kAppPurple),
      ),
      tabs: tabTitles.map((title) => Tab(text: title)).toList(),
    );
  }
}

Widget _buildGridItem(BuildContext context, int index) {
  // Get all posts from the mock repo
  final posts = MockPostRepo.allPosts; // Use the static getter

  if (index >= posts.length) {
    return Container(); // Return empty container if index out of bounds
  }

  final post = posts[index]; // Use the actual post at this index

  return GridPostTile(
    post: post,
    onTap: () {
      // Navigate to PostReaderPage
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => PostReaderPage(
                userId: 'user_1', // Replace with actual user ID
                initialPostId: post.id,
                source: PostSource.uploads, // or tagged based on current tab
                userName: 'Arjun Sethi', // Replace with actual user name
                profileImage:
                    'assets/images/profileImage.png', // Replace with actual profile image
              ),
          fullscreenDialog: true, // feels like a sheet
        ),
      );
    },
  );
}

// Sliver helper methods
List<Widget> UploadsSlivers({
  required int itemCount,
  required Widget Function(BuildContext, int) itemBuilder,
}) => [
  SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
    sliver: SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 0.85,
      ),
      delegate: SliverChildBuilderDelegate(itemBuilder, childCount: itemCount),
    ),
  ),
];

List<Widget> TaggedSlivers({required String message}) => [
  SliverPadding(
    padding: const EdgeInsets.all(20),
    sliver: SliverToBoxAdapter(child: Center(child: Text(message))),
  ),
];

List<Widget> QuickiesSlivers() => [
  const SliverToBoxAdapter(
    child: Center(child: Text('Quickies coming soon...')),
  ),
];

List<Widget> ClipsSlivers() => [
  const SliverToBoxAdapter(child: Center(child: Text('Clips coming soon...'))),
];

List<Widget> CollectionsSlivers() => [
  const SliverToBoxAdapter(
    child: Center(child: Text('Collections coming soon...')),
  ),
];
