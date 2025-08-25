// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/widgets/profile/profile_component.dart';
import 'package:sociord/widgets/profile/homePagePosts/profile_hero.dart';
import 'package:sociord/widgets/profile/profile_posts.dart'
    show UserType, ProfileViewType;
import 'package:sociord/widgets/profile/homePagePosts/profile_hero.dart'
    show RelationshipType;
import 'package:sociord/utils/asset_path_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String profileType = 'Creator';
  String category = 'Travel & Adventure';

  void toggleProfileType() {
    setState(() {
      if (profileType == 'Personal') {
        profileType = 'Creator';
        category = 'Travel & Adventure';
      } else {
        profileType = 'Personal';
        category = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userData = ProfileData(
      imageUrl: kProfilePic,
      name: 'Arjun Sethi',
      gender: 'Male',
      age: 'Millennial',
      location: 'Mumbai, India',
      handle: '@arjun.sethi',
      buddies: 0,
      subscriptions: 0,
      following: 0,
      creatorCategory: profileType == 'Creator' ? category : null,
      isVerified: false,
      hasHighlightData: true,
      highlightImages: null,
      highlightNames: null,
    );

    return ProfileComponent(
      userType: profileType == 'Creator' ? UserType.creator : UserType.explorer,
      viewType: ProfileViewType.own,
      relationship: RelationshipType.none,
      userData: userData,
      onEditProfilePressed: () {
        // Navigate to edit profile
        print('Edit profile pressed');
        context.go("/profile/becomeACreator");
      },
      onSettingsPressed: () {
        // Navigate to settings
        print('Settings pressed');
      },
      // Add the toggle profile type callback
      onToggleProfileType: toggleProfileType,
    );
  }
}
