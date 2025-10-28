import 'package:sociord/models/explore_models.dart';
import 'package:sociord/utils/asset_path_constants.dart';

class ExploreMockData {
  // Category filters for the top of explore page
  static List<ExploreCategory> categories = [
    ExploreCategory(
      id: '1',
      name: 'For Arjun',
      icon: 'favorite',
      isSelected: false,
    ),
    ExploreCategory(
      id: '2',
      name: 'Elite Circle',
      icon: 'emoji_events',
      isSelected: false,
    ),
    ExploreCategory(
      id: '3',
      name: 'Categories',
      icon: 'grid_view',
      isSelected: false,
    ),
    ExploreCategory(
      id: '4',
      name: 'Near Me',
      icon: 'location_on',
      isSelected: false,
    ),
    ExploreCategory(
      id: '5',
      name: 'Find Buddies',
      icon: 'group',
      isSelected: false,
    ),
  ];

  // Main content cards for the explore grid - "For Arjun" category
  static List<ExploreContentCard> forArjunContent = [
    ExploreContentCard(
      id: '1',
      title: 'Style Snapshots',
      imageUrl: kExploreCollectionVertical1,
      category: 'Fashion',
      contentType: 'Collection',
      isPremium: false,
    ),
    ExploreContentCard(
      id: '2',
      title: 'Weekend Wonders',
      imageUrl: kExploreCollectionVertical2,
      category: 'Lifestyle',
      contentType: 'Collection',
      isPremium: false,
    ),
    ExploreContentCard(
      id: '3',
      title: 'The Snack Attack...',
      imageUrl: kExploreCollectionVertical3,
      category: 'Food',
      contentType: 'Collection',
      isPremium: false,
    ),
    ExploreContentCard(
      id: '4',
      title: 'Behind the Lens',
      imageUrl: kExploreCollectionVertical4,
      category: 'Photography',
      contentType: 'Collection',
      isPremium: false,
    ),
    ExploreContentCard(
      id: '5',
      title: 'Chill Beats, Hot Vib...',
      imageUrl: kExploreImmersive1,
      category: 'Lifestyle',
      contentType: 'Quickies',
      isPremium: false,
    ),
    ExploreContentCard(
      id: '6',
      title: 'Snack-Sized Stories',
      imageUrl: kExploreImmersive2,
      category: 'Food',
      contentType: 'Quickies',
      isPremium: false,
    ),
  ];

  // Elite Circle content - user profiles
  static List<ExploreUserProfile> eliteCircleContent = [
    ExploreUserProfile(
      id: '1',
      handle: '@rajbakshiofficial',
      profileImageUrl: kExploreProfile1,
      category: 'Travel',
      followers: 12500,
      posts: 89,
    ),
    ExploreUserProfile(
      id: '2',
      handle: '@shellytravels',
      profileImageUrl: kExploreProfile2,
      category: 'Travel',
      followers: 8900,
      posts: 156,
    ),
    ExploreUserProfile(
      id: '3',
      handle: '@shivampatty',
      profileImageUrl: kExploreProfile3,
      category: 'Lifestyle',
      followers: 21000,
      posts: 234,
    ),
    ExploreUserProfile(
      id: '4',
      handle: '@anaya_dance',
      profileImageUrl: kExploreProfile4,
      category: 'Dance',
      followers: 15600,
      posts: 67,
    ),
  ];

  // Categories content - mixed content types
  static List<ExploreContentCard> categoriesContent = [
    ExploreContentCard(
      id: '1',
      title: 'Style Snapshots',
      imageUrl: kExploreCollectionVertical1,
      category: 'Fashion',
      contentType: 'Collection',
      isPremium: false,
    ),
    ExploreContentCard(
      id: '2',
      title: 'Weekend Wonders',
      imageUrl: kExploreCollectionVertical2,
      category: 'Lifestyle',
      contentType: 'Collection',
      isPremium: false,
    ),
    ExploreContentCard(
      id: '3',
      title: 'The Snack Attack...',
      imageUrl: kExploreCollectionVertical3,
      category: 'Food',
      contentType: 'Collection',
      isPremium: false,
    ),
    ExploreContentCard(
      id: '4',
      title: 'Behind the Lens',
      imageUrl: kExploreCollectionVertical4,
      category: 'Photography',
      contentType: 'Collection',
      isPremium: false,
    ),
  ];

  // Near Me content - location-based content
  static List<ExploreContentCard> nearMeContent = [
    ExploreContentCard(
      id: '1',
      title: 'Local Food Spots',
      imageUrl: kExploreQuickies1,
      category: 'Food',
      contentType: 'Quickies',
      isPremium: false,
    ),
    ExploreContentCard(
      id: '2',
      title: 'City Adventures',
      imageUrl: kExploreQuickies2,
      category: 'Travel',
      contentType: 'Quickies',
      isPremium: false,
    ),
    ExploreContentCard(
      id: '3',
      title: 'Local Events',
      imageUrl: kExploreQuickies3,
      category: 'Events',
      contentType: 'Quickies',
      isPremium: false,
    ),
    ExploreContentCard(
      id: '4',
      title: 'Community Stories',
      imageUrl: kExploreQuickies4,
      category: 'Community',
      contentType: 'Quickies',
      isPremium: false,
    ),
    ExploreContentCard(
      id: '5',
      title: 'Neighborhood Finds',
      imageUrl: kExploreQuickies5,
      category: 'Lifestyle',
      contentType: 'Quickies',
      isPremium: false,
    ),
    ExploreContentCard(
      id: '6',
      title: 'Local Art Scene',
      imageUrl: kExploreQuickies6,
      category: 'Art',
      contentType: 'Quickies',
      isPremium: false,
    ),
  ];

  // Find Buddies content - social connections
  static List<ExploreUserProfile> findBuddiesContent = [
    ExploreUserProfile(
      id: '1',
      handle: '@katieandkatie',
      profileImageUrl: kExploreProfile9,
      category: 'Lifestyle',
      followers: 3400,
      posts: 23,
    ),
    ExploreUserProfile(
      id: '2',
      handle: '@kingofnothing',
      profileImageUrl: kExploreProfile10,
      category: 'Fashion',
      followers: 5600,
      posts: 45,
    ),
    ExploreUserProfile(
      id: '3',
      handle: '@misty_mountai..',
      profileImageUrl: kExploreProfile11,
      category: 'Nature',
      followers: 7800,
      posts: 67,
    ),
    ExploreUserProfile(
      id: '4',
      handle: '@proudandhappy',
      profileImageUrl: kExploreProfile12,
      category: 'Art',
      followers: 4200,
      posts: 34,
    ),
  ];

  // Premium content sections
  static List<ExploreContentCard> holidayContent = [
    ExploreContentCard(
      id: '7',
      title: 'Deck the Wardr..',
      imageUrl: kExploreCollectionHorizontal1,
      category: 'Holiday',
      contentType: 'Collection',
      isPremium: true,
    ),
    ExploreContentCard(
      id: '8',
      title: 'Santa\'s Secret Sp..',
      imageUrl: kExploreCollectionHorizontal2,
      category: 'Holiday',
      contentType: 'Collection',
      isPremium: true,
    ),
    ExploreContentCard(
      id: '9',
      title: 'Yule Log & Chill',
      imageUrl: kExploreQuickies1,
      category: 'Holiday',
      contentType: 'Quickies',
      isPremium: true,
    ),
    ExploreContentCard(
      id: '10',
      title: 'Wrap It Up Right',
      imageUrl: kExploreQuickies2,
      category: 'Holiday',
      contentType: 'Quickies',
      isPremium: true,
    ),
  ];

  static List<ExploreContentCard> historicContent = [
    ExploreContentCard(
      id: '11',
      title: 'The First Exploration - Part 1',
      imageUrl: kExploreCollectionHorizontal1,
      category: 'History',
      contentType: 'Collection',
      isPremium: true,
    ),
    ExploreContentCard(
      id: '12',
      title: 'The First Exploration - Part 2',
      imageUrl: kExploreCollectionHorizontal2,
      category: 'History',
      contentType: 'Collection',
      isPremium: true,
    ),
  ];

  // Additional content cards
  static List<ExploreContentCard> additionalContent = [
    ExploreContentCard(
      id: '13',
      title: 'Art in a Flash',
      imageUrl: kExploreQuickies3,
      category: 'Art',
      contentType: 'Quickies',
      isPremium: false,
    ),
    ExploreContentCard(
      id: '14',
      title: 'Glow Up Guide 101',
      imageUrl: kExploreQuickies4,
      category: 'Beauty',
      contentType: 'Quickies',
      isPremium: false,
    ),
    ExploreContentCard(
      id: '15',
      title: 'Zen in 10',
      imageUrl: kExploreQuickies5,
      category: 'Wellness',
      contentType: 'Quickies',
      isPremium: false,
    ),
    ExploreContentCard(
      id: '16',
      title: 'Morning Mood..',
      imageUrl: kExploreQuickies6,
      category: 'Lifestyle',
      contentType: 'Quickies',
      isPremium: false,
    ),
    ExploreContentCard(
      id: '17',
      title: 'Kitchen Chronicles',
      imageUrl: kExploreQuickies7,
      category: 'Food',
      contentType: 'Quickies',
      isPremium: false,
    ),
    ExploreContentCard(
      id: '18',
      title: 'Breaking up',
      imageUrl: kExploreQuickies8,
      category: 'Philosophy',
      contentType: 'Quickies',
      isPremium: false,
    ),
  ];

  // Helper method to get content based on category
  static List<dynamic> getContentForCategory(String category) {
    switch (category) {
      case 'for_arjun':
        return forArjunContent;
      case 'elite_circle':
        return eliteCircleContent;
      case 'categories':
        return categoriesContent;
      case 'near_me':
        return nearMeContent;
      case 'find_buddies':
        return findBuddiesContent;
      default:
        return forArjunContent;
    }
  }

  // Elite Circle user profiles
  static List<ExploreUserProfile> regionalFavourites = [
    ExploreUserProfile(
      id: '1',
      handle: '@rajbakshiofficial',
      profileImageUrl: kExploreProfile1,
      category: 'Travel',
      followers: 12500,
      posts: 89,
    ),
    ExploreUserProfile(
      id: '2',
      handle: '@shellytravels',
      profileImageUrl: kExploreProfile2,
      category: 'Travel',
      followers: 8900,
      posts: 156,
    ),
    ExploreUserProfile(
      id: '3',
      handle: '@shivampatty',
      profileImageUrl: kExploreProfile3,
      category: 'Lifestyle',
      followers: 21000,
      posts: 234,
    ),
    ExploreUserProfile(
      id: '4',
      handle: '@anaya_dance',
      profileImageUrl: kExploreProfile4,
      category: 'Dance',
      followers: 15600,
      posts: 67,
    ),
  ];

  static List<ExploreUserProfile> bestInGenre = [
    ExploreUserProfile(
      id: '5',
      handle: '@skatersunite',
      profileImageUrl: kExploreProfile5,
      category: 'Sports',
      followers: 45000,
      posts: 189,
    ),
    ExploreUserProfile(
      id: '6',
      handle: '@ready_player',
      profileImageUrl: kExploreProfile6,
      category: 'Gaming',
      followers: 32000,
      posts: 445,
    ),
    ExploreUserProfile(
      id: '7',
      handle: '@rayola.speaks.t..',
      profileImageUrl: kExploreProfile7,
      category: 'Education',
      followers: 28000,
      posts: 123,
    ),
    ExploreUserProfile(
      id: '8',
      handle: '@jackieshroff',
      profileImageUrl: kExploreProfile8,
      category: 'Entertainment',
      followers: 89000,
      posts: 567,
    ),
  ];

  static List<ExploreUserProfile> newRisingStars = [
    ExploreUserProfile(
      id: '9',
      handle: '@katieandkatie',
      profileImageUrl: kExploreProfile9,
      category: 'Lifestyle',
      followers: 3400,
      posts: 23,
    ),
    ExploreUserProfile(
      id: '10',
      handle: '@kingofnothing',
      profileImageUrl: kExploreProfile10,
      category: 'Fashion',
      followers: 5600,
      posts: 45,
    ),
    ExploreUserProfile(
      id: '11',
      handle: '@misty_mountai..',
      profileImageUrl: kExploreProfile11,
      category: 'Nature',
      followers: 7800,
      posts: 67,
    ),
    ExploreUserProfile(
      id: '12',
      handle: '@proudandhappy',
      profileImageUrl: kExploreProfile12,
      category: 'Art',
      followers: 4200,
      posts: 34,
    ),
  ];

  static List<ExploreUserProfile> allTimeFavourites = [
    ExploreUserProfile(
      id: '13',
      handle: '@love_teachings...',
      profileImageUrl: kExploreProfile13,
      category: 'Education',
      followers: 67000,
      posts: 456,
    ),
    ExploreUserProfile(
      id: '14',
      handle: '@punjab_tigers2..',
      profileImageUrl: kExploreProfile14,
      category: 'Sports',
      followers: 89000,
      posts: 234,
    ),
    ExploreUserProfile(
      id: '15',
      handle: '@acapella_in_the..',
      profileImageUrl: kExploreProfile15,
      category: 'Music',
      followers: 45000,
      posts: 189,
    ),
    ExploreUserProfile(
      id: '16',
      handle: '@roaring_teams',
      profileImageUrl: kExploreProfile16,
      category: 'Team',
      followers: 78000,
      posts: 345,
    ),
  ];

  static List<ExploreUserProfile> promotionalCollaborations = [
    ExploreUserProfile(
      id: '17',
      handle: '@aliyah.alltheway',
      profileImageUrl: kExploreProfile17,
      category: 'Fashion',
      followers: 34000,
      posts: 234,
    ),
    ExploreUserProfile(
      id: '18',
      handle: '@pupsbeforemen',
      profileImageUrl: kExploreProfile18,
      category: 'Lifestyle',
      followers: 28000,
      posts: 156,
    ),
    ExploreUserProfile(
      id: '19',
      handle: '@toronto_boy',
      profileImageUrl: kExploreProfile19,
      category: 'Travel',
      followers: 45000,
      posts: 289,
    ),
    ExploreUserProfile(
      id: '20',
      handle: '@briancoxofficial',
      profileImageUrl: kExploreProfile20,
      category: 'Science',
      followers: 120000,
      posts: 567,
    ),
  ];

  // Immersive mode posts
  static List<ImmersivePost> immersivePosts = [
    ImmersivePost(
      id: '1',
      imageUrl: kExploreImmersive1,
      title: 'Looking after a newborn',
      creatorHandle: 'thatkindofgirl',
      category: 'Art, Design & Creativity',
      contentType: 'Quickies',
      likes: 20000,
      comments: 500000,
      views: 250000,
      rating: 'Excellent',
      timeAgo: '10 days ago',
      isSubscribed: false,
      isFollowing: false,
    ),
    ImmersivePost(
      id: '2',
      imageUrl: kExploreImmersive2,
      title: 'Kitchen adventures',
      creatorHandle: 'chef_master',
      category: 'Food & Cooking',
      contentType: 'Quickies',
      likes: 15000,
      comments: 300000,
      views: 180000,
      rating: 'Excellent',
      timeAgo: '5 days ago',
      isSubscribed: false,
      isFollowing: false,
    ),
  ];

  // Search suggestions
  static List<SearchSuggestion> searchSuggestions = [
    SearchSuggestion(id: '1', text: 'Chicken Pot Pie', category: 'Food'),
    SearchSuggestion(id: '2', text: 'How to jive', category: 'Dance'),
    SearchSuggestion(id: '3', text: 'How to build muscle', category: 'Fitness'),
    SearchSuggestion(
      id: '4',
      text: 'Date Ideas Romantic',
      category: 'Lifestyle',
    ),
    SearchSuggestion(id: '5', text: 'Dating in Mumbai', category: 'Lifestyle'),
  ];

  // Alternative search suggestions
  static List<SearchSuggestion> alternativeSearchSuggestions = [
    SearchSuggestion(id: '6', text: 'Spurring', category: 'General'),
    SearchSuggestion(id: '7', text: 'Starring', category: 'General'),
    SearchSuggestion(
      id: '8',
      text: 'How to fight with weapons',
      category: 'Sports',
    ),
    SearchSuggestion(
      id: '9',
      text: 'Scaring someone on halloween',
      category: 'Entertainment',
    ),
  ];
}
