import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';

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
        childAspectRatio: 1,
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
