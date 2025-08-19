import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';

enum UserType { explorer, creator }

enum ProfileViewType { own, other }

class ProfilePosts extends StatelessWidget {
  final String profileType;
  final UserType? userType;
  final ProfileViewType? viewType;

  const ProfilePosts({
    super.key,
    required this.profileType,
    this.userType,
    this.viewType,
  });

  @override
  Widget build(BuildContext context) {
    print(profileType);
    final bool isCreator = profileType == 'Creator';
    final currentUserType =
        userType ?? (isCreator ? UserType.creator : UserType.explorer);
    final currentViewType = viewType ?? ProfileViewType.own;

    final tabTitles =
        isCreator
            ? const ['Quickies', 'Clips', 'Collections']
            : const ['Uploads', 'Tagged'];
    final message = _getEmptyStateMessage(currentUserType, currentViewType);

    return Column(
      children: [
        DefaultTabController(
          length: tabTitles.length,
          child: Column(
            children: [
              SizedBox(
                height: 45,
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      child: Container(
                        height: 4,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: kBorderGreay,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    TabBar(
                      dividerHeight: 0,
                      labelColor: kAppBlack,
                      unselectedLabelColor: kAppBlack,
                      labelStyle: Theme.of(
                        context,
                      ).textTheme.headlineSmall!.copyWith(fontSize: 12),
                      indicator: UnderlineTabIndicator(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          width: 4,
                          color: kAppPurple,
                        ),
                        insets: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.29,
                        ),
                      ),
                      tabs: tabTitles.map((title) => Tab(text: title)).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50,
                child: TabBarView(
                  children:
                      tabTitles
                          .map(
                            (_) => Center(
                              child: Text(
                                message,
                                style:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodySmall!.copyWith(),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (currentViewType == ProfileViewType.own && isCreator)
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                backgroundColor: kAppPurple,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Upload Post',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontSize: 12,
                  color: kAppWhite,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getEmptyStateMessage(UserType userType, ProfileViewType viewType) {
    if (viewType == ProfileViewType.own) {
      return userType == UserType.creator
          ? 'Your journey starts here—upload your first post and share it with your audience.'
          : 'Your story starts here—upload your first post and share it with friends and family';
    } else {
      return userType == UserType.creator
          ? 'No content available yet.'
          : 'No posts available yet.';
    }
  }
}
