import 'package:flutter/material.dart';
import 'package:sociord/widgets/profile/profile_component.dart';
import 'package:sociord/widgets/profile/profile_hero.dart'
    show RelationshipType;
import 'package:sociord/widgets/profile/profile_posts.dart'
    show UserType, ProfileViewType;
import 'package:sociord/utils/asset_path_constants.dart';

// Example 1: Logged-in user's own profile (Creator)
class OwnCreatorProfileExample extends StatelessWidget {
  const OwnCreatorProfileExample({super.key});

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
      creatorCategory: 'Travel & Adventure',
    );

    return ProfileComponent(
      userType: UserType.creator,
      viewType: ProfileViewType.own,
      relationship: RelationshipType.none,
      userData: userData,
      onEditProfilePressed: () {
        // Navigate to edit profile
        print('Edit profile pressed');
      },
      onSettingsPressed: () {
        // Navigate to settings
        print('Settings pressed');
      },
    );
  }
}

// Example 2: Other user's buddy profile (Explorer)
class OtherBuddyProfileExample extends StatelessWidget {
  const OtherBuddyProfileExample({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = ProfileData(
      imageUrl: kProfilePic,
      name: 'Sarah Johnson',
      gender: 'Female',
      age: 'Millennial',
      location: 'Delhi, India',
      handle: '@sarah.j',
      buddies: 45,
      subscriptions: 0,
      following: 23,
    );

    return ProfileComponent(
      userType: UserType.explorer,
      viewType: ProfileViewType.other,
      relationship: RelationshipType.buddy,
      userData: userData,
      onBackPressed: () => Navigator.of(context).pop(),
      onMessagePressed: () {
        // Navigate to chat
        print('Message pressed');
      },
      onSharePressed: () {
        // Share profile
        print('Share pressed');
      },
    );
  }
}

// Example 3: Other user's creator profile (not subscribed)
class OtherCreatorProfileExample extends StatelessWidget {
  const OtherCreatorProfileExample({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = ProfileData(
      imageUrl: kProfilePic,
      name: 'Priya Sharma',
      gender: 'Female',
      age: 'Millennial',
      location: 'Bangalore, India',
      handle: '@priya.sharma',
      buddies: 0,
      subscriptions: 1250,
      following: 89,
      creatorCategory: 'Food & Cooking',
    );

    return ProfileComponent(
      userType: UserType.creator,
      viewType: ProfileViewType.other,
      relationship: RelationshipType.none,
      userData: userData,
      onBackPressed: () => Navigator.of(context).pop(),
      onSubscribePressed: () {
        // Subscribe to creator
        print('Subscribe pressed');
      },
      onMessagePressed: () {
        // Navigate to chat
        print('Message pressed');
      },
      onSharePressed: () {
        // Share profile
        print('Share pressed');
      },
    );
  }
}

// Example 4: Other user's creator profile (subscribed)
class SubscribedCreatorProfileExample extends StatelessWidget {
  const SubscribedCreatorProfileExample({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = ProfileData(
      imageUrl: kProfilePic,
      name: 'Rahul Verma',
      gender: 'Male',
      age: 'Millennial',
      location: 'Pune, India',
      handle: '@rahul.verma',
      buddies: 0,
      subscriptions: 890,
      following: 156,
      creatorCategory: 'Tech & Gadgets',
    );

    return ProfileComponent(
      userType: UserType.creator,
      viewType: ProfileViewType.other,
      relationship: RelationshipType.subscribed,
      userData: userData,
      onBackPressed: () => Navigator.of(context).pop(),
      onSubscribePressed: () {
        // Unsubscribe from creator
        print('Unsubscribe pressed');
      },
      onMessagePressed: () {
        // Navigate to chat
        print('Message pressed');
      },
      onSharePressed: () {
        // Share profile
        print('Share pressed');
      },
    );
  }
}
