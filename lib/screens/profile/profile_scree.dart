// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/profile/profile_banner.dart';
import 'package:sociord/widgets/profile/profile_hero.dart';
import 'package:sociord/widgets/profile/profile_highlight.dart';
import 'package:sociord/widgets/profile/profile_posts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String profileType = 'Creator';
  String category = 'Travel & Adventure';
  bool isHighlightExpanded = true;

  void toggleProfileType() {
    setState(() {
      if (profileType == 'Personal') {
        profileType = 'Creator';
      } else {
        profileType = 'Personal';
        category = '';
      }
    });
  }

  void toggleHighlight() {
    setState(() {
      isHighlightExpanded = !isHighlightExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {},
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Image.asset(kLogoText, height: 28),
              const SizedBox(width: 5),
              Image.asset(kChevronDown)
            ],
          ),
        ),
        backgroundColor: kAppWhite,
        actions: [
          GestureDetector(onTap: () {}, child: Image.asset(kNotification)),
          const SizedBox(width: 15),
          GestureDetector(onTap: () {}, child: Image.asset(kMessage)),
          const SizedBox(width: 15)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            ProfileBanner(
              title: profileType == 'Creator'
                  ? 'Congratulations, Arjun!'
                  : 'The Spotlight Awaits',
              desc: profileType == 'Creator'
                  ? 'Your Creator Profile is live.'
                  : 'Complete a few final details to unlock your creator account and begin earning for your creativity',
              image: profileType == 'Creator' ? kChanpagne : kCoins,
              cta: profileType == 'Creator'
                  ? 'Upload your first post'
                  : 'Complete now',
              ctaLink: () {},
            ),
            const SizedBox(height: 16),
            ProfileHero(
              imageUrl: kProfilePic,
              name: 'Arjun Sethi',
              gender: 'Male',
              age: "Milenial",
              location: 'Mumbai, India',
              buddies: 0,
              subscriptions: 0,
              following: 0,
              handle: '@arjun.sethi',
              profileType: profileType,
              creatorCategory: category,
              switchProfileType: toggleProfileType,
              syncContactOption: true,
            ),
            ProfileHighlight(
              isExpanded: isHighlightExpanded,
              profileType: profileType,
              onToggle: toggleHighlight,
            ),
            const SizedBox(height: 10),
            ProfilePosts(profileType: profileType)
          ],
        ),
      ),
    );
  }
}
