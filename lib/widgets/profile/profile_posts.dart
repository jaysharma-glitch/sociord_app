import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';

class ProfilePosts extends StatelessWidget {
  final String profileType;
  const ProfilePosts({super.key, required this.profileType});

  @override
  Widget build(BuildContext context) {
    print(profileType);
    final bool isCreator = profileType == 'Creator';
    final tabTitles = isCreator
        ? const ['Quickies', 'Clips', 'Collections']
        : const ['Uploads', 'Tagged'];
    final message = isCreator
        ? 'Your journey starts here—upload your first post and share it with your audience.'
        : 'Your story starts here—upload your first post and share it with friends and family';

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
                      labelStyle: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontSize: 12),
                      indicator: UnderlineTabIndicator(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(width: 4, color: kAppPurple),
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
                  children: tabTitles
                      .map((_) => Center(
                            child: Text(
                              message,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        isCreator
            ? Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    backgroundColor: kAppPurple,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Upload Post',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontSize: 12, color: kAppWhite),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOutlinedButton(context, Icons.image, 'Upload an image'),
                  const SizedBox(width: 16),
                  _buildOutlinedButton(
                      context, Icons.videocam, 'Upload a video'),
                ],
              ),
      ],
    );
  }

  Widget _buildOutlinedButton(
      BuildContext context, IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, size: 20, color: kAppBlack),
      label: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall!.copyWith(),
      ),
    );
  }
}
