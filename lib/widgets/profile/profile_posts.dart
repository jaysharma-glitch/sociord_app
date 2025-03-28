import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';

class ProfilePosts extends StatefulWidget {
  final profileType;
  const ProfilePosts({super.key, required this.profileType});

  @override
  State<ProfilePosts> createState() => _ProfilePostsState();
}

class _ProfilePostsState extends State<ProfilePosts> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.profileType == 'Creator'
            ? DefaultTabController(
                length: 3,
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
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          TabBar(
                            dividerHeight: 0,
                            labelColor: kAppBlack,
                            unselectedLabelColor: kAppBlack,
                            labelStyle: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontSize: 12,
                                ),
                            indicator: UnderlineTabIndicator(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                width: 4,
                                color: kAppPurple,
                              ),
                              insets: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.29),
                            ),
                            tabs: const [
                              Tab(text: 'Quickies'),
                              Tab(text: 'Clips'),
                              Tab(text: 'Collections'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      child: TabBarView(
                        children: [
                          Center(
                            child: Text(
                                'Your journey starts here—upload your first post and share it with your audience.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith()),
                          ),
                          Center(
                              child: Text(
                            'Your journey starts here—upload your first post and share it with your audience.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(),
                          )),
                          Center(
                              child: Text(
                            'Your journey starts here—upload your first post and share it with your audience.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : DefaultTabController(
                length: 2,
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
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          TabBar(
                            dividerHeight: 0,
                            labelColor: kAppBlack,
                            unselectedLabelColor: kAppBlack,
                            labelStyle: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontSize: 12,
                                ),
                            indicator: UnderlineTabIndicator(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                width: 4,
                                color: kAppPurple,
                              ),
                              insets: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.29),
                            ),
                            tabs: const [
                              Tab(text: 'Uploads'),
                              Tab(text: 'Tagged'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      child: TabBarView(
                        children: [
                          Center(
                            child: Text(
                                'Your story starts here—upload your first post and share it with friends and family',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith()),
                          ),
                          Center(
                              child: Text(
                            'Your story starts here—upload your first post and share it with friends and family',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

        const SizedBox(height: 16),

        // Upload Buttons
        widget.profileType == 'Creator'
            ? Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    backgroundColor: kAppPurple,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text('Upload Post',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontSize: 12)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(
                      Icons.image,
                      size: 20,
                      color: kAppBlack,
                    ),
                    label: Text(
                      'Upload an image',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {},
                    icon: const Icon(
                      Icons.videocam,
                      size: 20,
                      color: kAppBlack,
                    ),
                    label: Text(
                      'Upload a video',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(),
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}
