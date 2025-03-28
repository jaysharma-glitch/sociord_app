// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/profile/profile_banner.dart';
import 'package:sociord/widgets/profile/profile_hero.dart';
import 'package:sociord/widgets/profile/profile_highlight.dart';
import 'package:sociord/widgets/profile/profile_posts.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var profileType = 'Creator';

  var category = 'Travel & Adventure';

  bool isHighlightExpanded = true;

  switchProfile() {
    setState(() {
      if (profileType == 'Personal') {
        profileType = 'Creator';
      } else {
        profileType = 'Personal';
        category = '';
      }
    });
  }

  dropDownClick() {
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
              SizedBox(
                height: profileType == 'Creator' ? 0 : 8,
              ),
              profileType == 'Creator'
                  ? ProfileBanner(
                      title: 'Congratulations, Arjun!',
                      desc: 'Your Creator Profile is live.',
                      image: kChanpagne,
                      cta: 'Upload your first post',
                      ctaLink: () {},
                    )
                  : ProfileBanner(
                      title: 'The Spotlight Awaits',
                      desc:
                          'Complete a few final details to unlock your creator account and begin earning for your creativity',
                      image: kCoins,
                      cta: 'Complete now',
                      ctaLink: () {},
                    ),
              const SizedBox(height: 16),

              // Profile Picture & Info
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
                switchProfileType: switchProfile,
              ),
              // Highlights
              ProfileHighlight(
                  isHighlightExpanded: isHighlightExpanded,
                  profileType: profileType,
                  dropDownClick: dropDownClick),
              const SizedBox(height: 10),

              // Upload Tabs
              ProfilePosts(profileType: profileType)
            ],
          ),
        ),
      ),
    );
  }
}
