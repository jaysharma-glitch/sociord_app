import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/constants/text_styles.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/utils/routes.dart';
import 'package:sociord/widgets/profile/homePagePosts/profile_banner.dart';

class ApplyFinal extends StatelessWidget {
  final PageController pageController;
  const ApplyFinal({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          ProfileBanner(
            centerAlign: true,
            title: 'Grow Faster by joining a channel',
            desc:
                'Join a high-impact network of influencers to reach more people, drive greater engagement, and boost your total revenue through the power of volume',
            image: kRocket,
            ctaLink: () {},
          ),
          const SizedBox(height: 110),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wider Reach',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall!.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: kAppBlack,
                            ),
                          ),
                          Text(
                            'More viewers are drawn to group packages at reduced prices, increasing your exposure.',
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wider Reach',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall!.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: kAppBlack,
                            ),
                          ),
                          Text(
                            'More viewers are drawn to group packages at reduced prices, increasing your exposure.',
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'More Brand Deals',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall!.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: kAppBlack,
                            ),
                          ),
                          Text(
                            'Attract collaborations with top brands as your influence grows.',
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Boosted Credibility',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall!.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: kAppBlack,
                            ),
                          ),
                          Text(
                            'Build trust by being part of a high-profile, respected influencer network.',
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      context.go(profileRoute);
                    },
                    child: Text(
                      'Apply and Continue',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      context.go(profileRoute);
                      // Navigator.pushNamed(context, '/personality-flow');
                      // Navigator.pushNamed(context, '/profile-pic');
                    },
                    child: Text(
                      'Continue without applying',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: kAppPurple),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
