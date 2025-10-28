// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/widgets/profile/profile_component.dart';
import 'package:sociord/widgets/profile/homePagePosts/profile_hero.dart';
import 'package:sociord/widgets/profile/profile_posts.dart'
    show UserType, ProfileViewType;
import 'package:sociord/widgets/profile/homePagePosts/profile_hero.dart'
    show RelationshipType;
import 'package:sociord/utils/asset_path_constants.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String category = 'Travel & Adventure';

  void toggleProfileType() {
    final user = ref.read(userNotifierProvider);
    final currentType = user.profileType ?? 'Personal';
    final newType = currentType == 'Personal' ? 'Creator' : 'Personal';

    ref.read(userNotifierProvider.notifier).setProfileType(newType);

    setState(() {
      if (newType == 'Creator') {
        category = 'Travel & Adventure';
      } else {
        category = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userNotifierProvider);
    final profileType = user.profileType ?? 'Personal';
    final isCreator = profileType == 'Creator' || profileType == 'Business';

    final userData = ProfileData(
      imageUrl: user.profilePic ?? kProfilePic,
      name: '${user.firstName ?? 'Arjun'} ${user.lastName ?? 'Sethi'}',
      gender: user.gender ?? 'Male',
      age: 'Millennial',
      location: user.location?.city ?? 'Mumbai, India',
      handle: '@${user.userName ?? 'arjun.sethi'}',
      buddies: 0,
      subscriptions: 0,
      following: 0,
      creatorCategory: isCreator ? category : null,
      isVerified: false,
      hasHighlightData: true,
      highlightImages: null,
      highlightNames: null,
    );

    return ProfileComponent(
      userType: isCreator ? UserType.creator : UserType.explorer,
      viewType: ProfileViewType.own,
      relationship: RelationshipType.none,
      userData: userData,
      onEditProfilePressed: () {
        // Navigate to edit profile
        // Edit profile pressed
        context.go("/profile/becomeACreator");
      },
      onSettingsPressed: () {
        // Navigate to settings
        // Settings pressed
      },
      // Add the toggle profile type callback
      onToggleProfileType: toggleProfileType,
    );
  }
}
