// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/gradient_text.dart';

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
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kAppPurple, kAppOrange],
                      begin: Alignment.topLeft, // Gradient starts from top-left
                      end: Alignment
                          .bottomRight, // Gradient ends at bottom-right
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 15,
                            ),
                            Text('The Spotlight Awaits',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(fontSize: 12)),
                            const SizedBox(
                              height: 2,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Text(
                                'Complete a few final details to unlock your creator account and begin earning for your creativity',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(fontSize: 10, color: kAppWhite),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                backgroundColor: kAppWhite,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(5),
                                    topRight: Radius.circular(5),
                                    bottomLeft: Radius.zero,
                                    bottomRight: Radius.zero,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GradientText(
                                    text: 'Complete now',
                                    gradient: const LinearGradient(
                                      colors: [kAppPurple, kAppOrange],
                                      begin: Alignment
                                          .topLeft, // Gradient starts from top-left
                                      end: Alignment
                                          .bottomRight, // Gradient ends at bottom-right
                                    ),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Image.asset(kRightArrow)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                          top: -20, right: -8, child: Image.asset(kCoins)),
                    ],
                  )),
              const SizedBox(height: 16),

              // Profile Picture & Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.asset(kProfilePic)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Arjun Sethi',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: kAppBlack),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_rounded,
                            color: kAppPurple,
                            size: 18,
                          ),
                          Text(
                            'Male, Millenial',
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        ],
                      ),

                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_pin,
                            color: kAppPurple,
                            size: 18,
                          ),
                          Text(
                            'Mumbai, India',
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Sync Contacts
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: kBorderGreay,
                            borderRadius: BorderRadius.circular(5)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Want to see who's on Sociord?",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(fontSize: 9),
                            ),
                            GestureDetector(
                                onTap: () {},
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("Sync Contacts",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: kAppPurple)),
                                    const SizedBox(width: 2),
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 2,
                                        ),
                                        Image.asset(
                                          kRightArrow,
                                          height: 10,
                                          width: 10,
                                        ),
                                      ],
                                    )
                                  ],
                                ))
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Stats
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 5,
                            ),
                            Column(
                              children: [
                                Text('0',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                            fontSize: 15, color: kAppBlack)),
                                Text('Buddies',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith())
                              ],
                            ),
                            const SizedBox(width: 5),
                            Column(
                              children: [
                                Text('0',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                            fontSize: 15, color: kAppBlack)),
                                Text('Subscriptions',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith())
                              ],
                            ),
                            const SizedBox(width: 5),
                            Column(
                              children: [
                                Text('0',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                            fontSize: 15, color: kAppBlack)),
                                Text('Following',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith())
                              ],
                            ),
                            const SizedBox(width: 5),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    '@arjun.sethi',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontFamily: "Gibson"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.open_in_new,
                    size: 15,
                    color: kAppPurple,
                  )
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Text(
                    'Personal Profile',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontFamily: "Gibson"),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
              // Buttons: Edit Profile & Become a Creator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text('Edit Profile'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple),
                    child: const Text('Become a Creator'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Highlights
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Arjun’s Highlights',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),

              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, size: 40),
              ),
              const SizedBox(height: 8),
              const Text('Got Married? Share the memory',
                  style: TextStyle(color: Colors.purple)),

              const SizedBox(height: 16),

              // Upload Tabs
              DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      labelColor: Colors.purple,
                      unselectedLabelColor: Colors.grey,
                      tabs: [
                        Tab(text: 'Uploads'),
                        Tab(text: 'Tagged'),
                      ],
                    ),
                    Container(
                      height: 200,
                      child: const TabBarView(
                        children: [
                          Center(child: Text('No uploads yet')),
                          Center(child: Text('No tagged photos yet')),
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
                    icon: const Icon(Icons.image),
                    label: const Text('Upload an image'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.videocam),
                    label: const Text('Upload a video'),
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
