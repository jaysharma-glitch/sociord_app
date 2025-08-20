import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/widgets/profile/profile_component.dart';
import 'package:sociord/widgets/profile/profile_hero.dart'
    show RelationshipType;
import 'package:sociord/widgets/profile/profile_posts.dart'
    show UserType, ProfileViewType;
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/constants/color.dart';

class BuddyProfileScreen extends StatelessWidget {
  final String username;
  final String profileImage;
  final RelationshipType relationship;

  const BuddyProfileScreen({
    super.key,
    required this.username,
    required this.profileImage,
    this.relationship = RelationshipType.none,
  });

  @override
  Widget build(BuildContext context) {
    // Mock data for the buddy - in real app this would come from API
    final userData = _getBuddyData(username, profileImage);

    return ProfileComponent(
      userType: UserType.explorer,
      viewType: ProfileViewType.other,
      relationship: relationship,
      userData: userData,
      onBackPressed: () => context.pop(),
      onAddBuddyPressed: () {
        // Add as buddy logic
        print('Add as buddy pressed for $username');
        // Show success message or update relationship
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added $username as buddy!'),
            backgroundColor: Colors.green,
          ),
        );
      },
      onMessagePressed: () {
        // Navigate to chat
        print('Message pressed for $username');
        // context.go('/chat/$username');
      },
      onSharePressed: () {
        // Share profile
        print('Share profile for $username');
        // Share.share('Check out $username on Sociord!');
      },
      // Pass profile image for highlights
      profileImage: userData.imageUrl,
    );
  }

  ProfileData _getBuddyData(String username, String profileImage) {
    // Mock data - in real app this would come from API based on username
    final Map<String, Map<String, dynamic>> buddyData = {
      'emma.wave': {
        'name': 'Emma Wave',
        'gender': 'Female',
        'age': 'Millennial',
        'location': 'Mumbai, India',
        'handle': '@emma.wave',
        'buddies': 45,
        'subscriptions': 0,
        'following': 23,
        'profileImage': kBuddy1,
        'uploads': kBuddyUploads, // All upload images
        'highlights': kBuddyHighlights, // All highlight images
      },
      'oliver_in_focus': {
        'name': 'Oliver Smith',
        'gender': 'Male',
        'age': 'Millennial',
        'location': 'Delhi, India',
        'handle': '@oliver_in_focus',
        'buddies': 32,
        'subscriptions': 0,
        'following': 18,
        'profileImage': kBuddy2,
        'uploads': kBuddyUploads, // All upload images
        'highlights': kBuddyHighlights, // All highlight images
      },
      'liamdavis': {
        'name': 'Liam Davis',
        'gender': 'Male',
        'age': 'Millennial',
        'location': 'Bangalore, India',
        'handle': '@liamdavis',
        'buddies': 28,
        'subscriptions': 0,
        'following': 15,
        'profileImage': kBuddy3,
        'uploads': kBuddyUploads, // All upload images
        'highlights': kBuddyHighlights, // All highlight images
      },
      'diya.codes': {
        'name': 'Diya Patel',
        'gender': 'Female',
        'age': 'Millennial',
        'location': 'Pune, India',
        'handle': '@diya.codes',
        'buddies': 67,
        'subscriptions': 0,
        'following': 42,
        'profileImage': kBuddy4,
        'uploads': kBuddyUploads, // All upload images
        'highlights': kBuddyHighlights, // All highlight images
      },
      'noah.the.explorer': {
        'name': 'Noah Johnson',
        'gender': 'Male',
        'age': 'Millennial',
        'location': 'Chennai, India',
        'handle': '@noah.the.explorer',
        'buddies': 39,
        'subscriptions': 0,
        'following': 27,
        'profileImage': kBuddy5,
        'uploads': kBuddyUploads, // All upload images
        'highlights': kBuddyHighlights, // All highlight images
      },
      'amara.now': {
        'name': 'Amara Singh',
        'gender': 'Female',
        'age': 'Millennial',
        'location': 'Hyderabad, India',
        'handle': '@amara.now',
        'buddies': 54,
        'subscriptions': 0,
        'following': 31,
        'profileImage': kBuddy6,
        'uploads': kBuddyUploads, // All upload images
        'highlights': kBuddyHighlights, // All highlight images
      },
    };

    final data =
        buddyData[username] ??
        {
          'name': username,
          'gender': 'Unknown',
          'age': 'Millennial',
          'location': 'India',
          'handle': '@$username',
          'buddies': 0,
          'subscriptions': 0,
          'following': 0,
          'profileImage': kProfilePic,
          'uploads': kBuddyUploads, // All upload images
          'highlights': kBuddyHighlights, // All highlight images
        };

    return ProfileData(
      imageUrl: data['profileImage'] ?? profileImage,
      name: data['name'],
      gender: data['gender'],
      age: data['age'],
      location: data['location'],
      handle: data['handle'],
      buddies: data['buddies'],
      subscriptions: data['subscriptions'],
      following: data['following'],
      hasHighlightData:
          (data['highlights'] as List)
              .isNotEmpty, // Show highlights only if buddy has highlight data
      highlightImages: data['highlights'] as List<String>?,
      highlightNames: [
        'I KNOW..',
        'The Best day of..',
        'Honeymoon',
        'Progress in the I..',
        'Reunions',
        'This one is to di..',
      ],
    );
  }
}
