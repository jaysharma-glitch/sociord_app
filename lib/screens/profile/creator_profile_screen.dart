import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/widgets/profile/profile_component.dart';
import 'package:sociord/widgets/profile/profile_posts.dart'
    show UserType, ProfileViewType;
import 'package:sociord/widgets/profile/homePagePosts/profile_hero.dart';
import 'package:sociord/utils/asset_path_constants.dart';

class CreatorProfileScreen extends StatelessWidget {
  final String username;
  final String profileImage;
  final RelationshipType relationship;

  const CreatorProfileScreen({
    super.key,
    required this.username,
    required this.profileImage,
    this.relationship = RelationshipType.none,
  });

  @override
  Widget build(BuildContext context) {
    // Mock data for the creator - in real app this would come from API
    final userData = _getCreatorData(username, profileImage);

    return ProfileComponent(
      userType: UserType.creator,
      viewType: ProfileViewType.other,
      relationship: relationship,
      userData: userData,
      onBackPressed: () => context.pop(),
      onSubscribePressed: () {
        // Subscribe logic
        print('Subscribe pressed for $username');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subscribed to $username!'),
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

  ProfileData _getCreatorData(String username, String profileImage) {
    // Mock data - in real app this would come from API based on username
    final Map<String, Map<String, dynamic>> creatorData = {
      'sarah.creative': {
        'name': 'Sarah Creative',
        'gender': 'Female',
        'age': 'Millennial',
        'location': 'Mumbai, India',
        'handle': '@sarah.creative',
        'subscribers': 200000,
        'followers': 1000000,
        'rating': 8.5,
        'profileImage': kCreator1,
        'creatorCategory': 'Lifestyle',
        'showcase': kCreatorShowcase, // Images 10-15 for showcase
        'quickies': kCreatorQuickies, // Images 1-9 for quickies
      },
      'alex.tech': {
        'name': 'Alex Tech',
        'gender': 'Male',
        'age': 'Millennial',
        'location': 'Delhi, India',
        'handle': '@alex.tech',
        'subscribers': 150000,
        'followers': 800000,
        'rating': 8.2,
        'profileImage': kCreator2,
        'creatorCategory': 'Technology',
        'showcase': kCreatorShowcase,
        'quickies': kCreatorQuickies,
      },
      'maya.fitness': {
        'name': 'Maya Fitness',
        'gender': 'Female',
        'age': 'Millennial',
        'location': 'Bangalore, India',
        'handle': '@maya.fitness',
        'subscribers': 300000,
        'followers': 1200000,
        'rating': 8.8,
        'profileImage': kCreator3,
        'creatorCategory': 'Fitness',
        'showcase': kCreatorShowcase,
        'quickies': kCreatorQuickies,
      },
      'david.food': {
        'name': 'David Food',
        'gender': 'Male',
        'age': 'Millennial',
        'location': 'Pune, India',
        'handle': '@david.food',
        'subscribers': 180000,
        'followers': 900000,
        'rating': 8.3,
        'profileImage': kCreator4,
        'creatorCategory': 'Food',
        'showcase': kCreatorShowcase,
        'quickies': kCreatorQuickies,
      },
      'lisa.travel': {
        'name': 'Lisa Travel',
        'gender': 'Female',
        'age': 'Millennial',
        'location': 'Chennai, India',
        'handle': '@lisa.travel',
        'subscribers': 120000,
        'followers': 600000,
        'rating': 8.1,
        'profileImage': kCreator5,
        'creatorCategory': 'Travel',
        'showcase': kCreatorShowcase,
        'quickies': kCreatorQuickies,
      },
      'james.art': {
        'name': 'James Art',
        'gender': 'Male',
        'age': 'Millennial',
        'location': 'Hyderabad, India',
        'handle': '@james.art',
        'subscribers': 90000,
        'followers': 450000,
        'rating': 7.9,
        'profileImage': kCreator6,
        'creatorCategory': 'Art',
        'showcase': kCreatorShowcase,
        'quickies': kCreatorQuickies,
      },
      'emma.fashion': {
        'name': 'Emma Fashion',
        'gender': 'Female',
        'age': 'Millennial',
        'location': 'Kolkata, India',
        'handle': '@emma.fashion',
        'subscribers': 250000,
        'followers': 1100000,
        'rating': 8.6,
        'profileImage': kCreator7,
        'creatorCategory': 'Fashion',
        'showcase': kCreatorShowcase,
        'quickies': kCreatorQuickies,
      },
      'mike.music': {
        'name': 'Mike Music',
        'gender': 'Male',
        'age': 'Millennial',
        'location': 'Ahmedabad, India',
        'handle': '@mike.music',
        'subscribers': 160000,
        'followers': 750000,
        'rating': 8.4,
        'profileImage': kCreator8,
        'creatorCategory': 'Music',
        'showcase': kCreatorShowcase,
        'quickies': kCreatorQuickies,
      },
    };

    final data =
        creatorData[username] ??
        {
          'name': username,
          'gender': 'Unknown',
          'age': 'Millennial',
          'location': 'India',
          'handle': '@$username',
          'subscribers': 0,
          'followers': 0,
          'rating': 0.0,
          'profileImage': kProfilePic,
          'creatorCategory': 'Creator',
          'showcase': kCreatorShowcase,
          'quickies': kCreatorQuickies,
        };

    final showcase = data['showcase'] as List<String>? ?? [];
    return ProfileData(
      imageUrl: data['profileImage'] ?? profileImage,
      name: data['name'],
      gender: data['gender'],
      age: data['age'],
      location: data['location'],
      handle: data['handle'],
      buddies: 0, // Not used for creators
      subscriptions: 0, // Not used for creators
      following: 0, // Not used for creators
      subscribers: data['subscribers'],
      followers: data['followers'],
      rating: data['rating'],
      creatorCategory: data['creatorCategory'],
      hasHighlightData: showcase.isNotEmpty,
      highlightImages: showcase.isNotEmpty ? showcase : null,
      highlightNames:
          showcase.isNotEmpty
              ? [
                'Best Work',
                'Featured',
                'Award Winner',
                'Trending',
                'Viral Moment',
                'Collaboration',
              ]
              : null,
    );
  }
}
