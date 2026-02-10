import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/widgets/profile/buddyProfilePost/post_reader_page.dart';
import 'package:sociord/widgets/profile/buddyProfilePost/post_source.dart';
import 'package:sociord/mock_data/clips_mock_data.dart';
import 'package:sociord/models/clip_model.dart';
import 'package:sociord/widgets/profile/clips_header.dart';
import 'package:sociord/mock_data/collections_mock_data.dart';
import 'package:sociord/models/collection_model.dart';
import 'package:sociord/widgets/profile/collections_header.dart';
import 'package:sociord/widgets/common/horizontal_image_card.dart';

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

// Empty-state slivers for own profile uploads tab: message + action buttons.
List<Widget> UploadsEmptyStateSlivers({
  required String message,
  required VoidCallback onUploadImage,
  required VoidCallback onUploadVideo,
}) =>
    [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: kAppBlack,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onUploadImage,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: kAppPurple, width: 1.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined, color: kAppBlack, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Upload an image',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: kAppBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onUploadVideo,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: kAppPurple, width: 1.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam_outlined, color: kAppBlack, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Upload a video',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: kAppBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];

List<Widget> QuickiesSlivers({
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

List<Widget> ClipsSlivers({
  bool isLandscapeMode = false,
  ValueChanged<bool>? onOrientationChanged,
}) => [
  // Header with toggle and sort
  SliverToBoxAdapter(
    child: ClipsHeader(
      initialValue: isLandscapeMode,
      onOrientationChanged:
          onOrientationChanged ??
          (isLandscape) {
            // Default callback if none provided
            print(
              'Orientation changed to: ${isLandscape ? 'Landscape' : 'Portrait'}',
            );
          },
    ),
  ),
  // Grid content - Dynamic based on orientation
  SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    sliver: SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            isLandscapeMode ? 1 : 2, // 1 column for landscape, 2 for portrait
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio:
            isLandscapeMode ? 1.7 : 0.64, // Different aspect ratios
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final clips =
              isLandscapeMode
                  ? ClipsMockData.landscapeClips
                  : ClipsMockData.portraitClips;
          if (index >= clips.length) return null;
          final clip = clips[index];
          return _buildClipCard(context, clip, isLandscape: isLandscapeMode);
        },
        childCount:
            isLandscapeMode
                ? ClipsMockData.landscapeClips.length
                : ClipsMockData.portraitClips.length,
      ),
    ),
  ),
];

List<Widget> CollectionsSlivers({
  bool isHorizontalMode = true,
  ValueChanged<bool>? onOrientationChanged,
}) => [
  // Header with toggle and sort
  SliverToBoxAdapter(
    child: CollectionsHeader(
      initialValue: isHorizontalMode,
      onOrientationChanged:
          onOrientationChanged ??
          (isHorizontal) {
            // Default callback if none provided
            print(
              'Collections orientation changed to: ${isHorizontal ? 'Horizontal' : 'Vertical'}',
            );
          },
    ),
  ),
  // Collections content
  SliverList(
    delegate: SliverChildBuilderDelegate(
      (context, index) {
        final collections =
            isHorizontalMode
                ? CollectionsMockData.landscapeCollections
                : CollectionsMockData.portraitCollections;
        final collection = collections[index];
        return _buildCollectionSection(context, collection, isHorizontalMode);
      },
      childCount:
          isHorizontalMode
              ? CollectionsMockData.landscapeCollections.length
              : CollectionsMockData.portraitCollections.length,
    ),
  ),
];

Widget _buildClipCard(
  BuildContext context,
  ClipModel clip, {
  bool isLandscape = false,
}) {
  return HorizontalImageCard(
    imageUrl: clip.imageUrl,
    width: 120,
    height: 160,
    borderRadius: 5,
    onTap: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => PostReaderPage(
                userId: 'creator_1',
                initialPostId: clip.id,
                source: PostSource.uploads,
                userName: 'Creator Name',
                profileImage: 'assets/images/creator/1.jpeg',
                isCreator: true, // This is creator content
              ),
          fullscreenDialog: true,
        ),
      );
    },
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Container(
        //   width: double.infinity,
        //   decoration: BoxDecoration(
        //     borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        //     image: DecorationImage(
        //       image: AssetImage(clip.imageUrl),
        //       fit: BoxFit.cover,
        //     ),
        //   ),
        // ),

        // Stats
        Row(
          children: [
            Icon(
              clip.rating == 'Excellent' ? Icons.star : Icons.star_border,
              size: 12,
              color: clip.rating == 'Excellent' ? Colors.amber : Colors.grey,
            ),
            const SizedBox(width: 2),
            Text(
              _formatNumber(clip.likes),
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: kAppBlack, fontSize: 10),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chat_bubble_outline, size: 12, color: Colors.grey),
            const SizedBox(width: 2),
            Text(
              _formatNumber(clip.comments),
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: kAppBlack, fontSize: 10),
            ),
            const Spacer(),
            Icon(Icons.share, size: 12, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          clip.title,
          style: Theme.of(context).textTheme.titleSmall!.copyWith(
            color: kAppBlack,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        // Views and time
        Text(
          '${clip.rating} | ${_formatNumber(clip.views)} Views | ${clip.timeAgo}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall!.copyWith(color: kAppBlack, fontSize: 10),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

String _formatNumber(int number) {
  if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed(1)}M';
  } else if (number >= 1000) {
    return '${(number / 1000).toStringAsFixed(1)}K';
  }
  return number.toString();
}

Widget _buildCollectionSection(
  BuildContext context,
  CollectionModel collection,
  bool isHorizontalMode,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Collection title and rating
        Row(
          children: [
            Expanded(
              child: Text(
                collection.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: kAppBlack,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.star_rounded,
              size: 16,
              color:
                  collection.rating == 'Excellent'
                      ? kAppPurple
                      : collection.rating == 'Good'
                      ? kAppYellow
                      : kAppBlack,
            ),
            const SizedBox(width: 4),
            Text(
              'Rated ${collection.rating}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Horizontal slider with posts
        SizedBox(
          height:
              isHorizontalMode
                  ? 120
                  : 160, // Shorter for horizontal, normal for portrait
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: collection.posts.length,
            itemBuilder: (context, index) {
              final post = collection.posts[index];
              return HorizontalImageCard(
                imageUrl: post.imageUrl,
                width:
                    isHorizontalMode
                        ? 200
                        : 120, // Wider for horizontal, normal for portrait
                height:
                    isHorizontalMode
                        ? 120
                        : 160, // Shorter for horizontal, normal for portrait
                borderRadius: 5,
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}
