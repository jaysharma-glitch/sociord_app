import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/utils/routes.dart';

class ProfileHero extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String gender;
  final String age;
  final location;
  final syncContactOption;
  final int buddies;
  final int subscriptions;
  final int following;
  final String handle;
  final String profileType;

  final String creatorCategory;
  const ProfileHero(
      {super.key,
      required this.imageUrl,
      required this.name,
      required this.gender,
      required this.age,
      required this.location,
      this.syncContactOption = true,
      required this.buddies,
      required this.subscriptions,
      required this.following,
      required this.handle,
      required this.profileType,
      this.creatorCategory = ''});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(imageUrl)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
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
                      '$gender, $age',
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
                      location,
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  ],
                ),
                const SizedBox(height: 5),
                // Sync Contacts
                syncContactOption
                    ? Container(
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
                      )
                    : const SizedBox(),
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
                          Text(buddies.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(fontSize: 15, color: kAppBlack)),
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
                          Text(subscriptions.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(fontSize: 15, color: kAppBlack)),
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
                          Text(following.toString(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(fontSize: 15, color: kAppBlack)),
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
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              'Personal Profile',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(fontFamily: "Gibson", fontSize: 10),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        // Buttons: Edit Profile & Become a Creator
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                backgroundColor: kAppBlack,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Edit Profile',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontSize: 12)),
            ),
            const SizedBox(width: 5),
            ElevatedButton(
              onPressed: () {
                context.go(becomeACreator);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                backgroundColor: kAppPurple,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Become a Creator',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
