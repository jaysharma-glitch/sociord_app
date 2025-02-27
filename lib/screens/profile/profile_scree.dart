// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/profile/profile_banner.dart';
import 'package:sociord/widgets/profile/profile_hero.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {},
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(
                kLogoText,
                height: 28,
              ),
              const SizedBox(
                width: 5,
              ),
              Image.asset(kChevronDown)
            ],
          ),
        ),
        backgroundColor: kAppWhite,
        actions: [
          GestureDetector(
            onTap: () {},
            child: Image.asset(
              kNotification,
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          GestureDetector(
            onTap: () {},
            child: Image.asset(kMessage),
          ),
          const SizedBox(
            width: 15,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Banner
              const SizedBox(
                height: 8,
              ),
              ProfileBanner(
                title: 'The Spotlight Awaits',
                desc:
                    'Complete a few final details to unlock your creator account and begin earning for your creativity',
                image: kCoins,
                cta: 'Complete now',
                ctaLink: () {},
              ),
              const SizedBox(height: 16),

              // Profile Picture & Info
              const ProfileHero(
                imageUrl: kProfilePic,
                name: 'Arjun Sethi',
                gender: 'Male',
                age: "Milenial",
                location: 'Mumbai, India',
                buddies: 0,
                subscriptions: 0,
                following: 0,
                handle: '@arjun.sethi',
                profileType: 'Personal',
              ),
              // Highlights
              Row(
                children: [
                  Text(
                    'Arjun’s Highlights',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontSize: 15, color: kAppPurple),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Image.asset(kChevronDownPurple),
                ],
              ),
              Text(
                'Capture your life’s highlights and relive your best moments.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),

              Container(
                width: 80,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add,
                      size: 35,
                      color: kAppPurple,
                    ),
                    Center(
                      child: Text('Got Married? \nShare the memory',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontSize: 9, color: kAppPurple)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Upload Tabs
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Positioned(
                          bottom: 0,
                          child: Container(
                            height: 4,
                            width: double.infinity,
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
              Row(
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
          ),
        ),
      ),
    );
  }
}
