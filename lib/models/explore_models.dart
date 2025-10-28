class ExploreContentCard {
  final String id;
  final String title;
  final String imageUrl;
  final String? category;
  final String? contentType;
  final bool isPremium;
  final String? creatorHandle;
  final int? views;
  final double? rating;

  ExploreContentCard({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.category,
    this.contentType,
    this.isPremium = false,
    this.creatorHandle,
    this.views,
    this.rating,
  });
}

class ExploreUserProfile {
  final String id;
  final String handle;
  final String profileImageUrl;
  final String? category;
  final bool isVerified;
  final int followers;
  final int posts;

  ExploreUserProfile({
    required this.id,
    required this.handle,
    required this.profileImageUrl,
    this.category,
    this.isVerified = false,
    this.followers = 0,
    this.posts = 0,
  });
}

class ImmersivePost {
  final String id;
  final String imageUrl;
  final String title;
  final String creatorHandle;
  final String category;
  final String contentType;
  final int likes;
  final int comments;
  final int views;
  final String rating;
  final String timeAgo;
  final bool isSubscribed;
  final bool isFollowing;

  ImmersivePost({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.creatorHandle,
    required this.category,
    required this.contentType,
    required this.likes,
    required this.comments,
    required this.views,
    required this.rating,
    required this.timeAgo,
    this.isSubscribed = false,
    this.isFollowing = false,
  });
}

class ExploreCategory {
  final String id;
  final String name;
  final String icon; // Material Icon name or image path
  final bool isSelected;
  final bool
  isMaterialIcon; // true if icon is Material Icon name, false if image path

  ExploreCategory({
    required this.id,
    required this.name,
    required this.icon,
    this.isSelected = false,
    this.isMaterialIcon = true, // default to Material Icons
  });
}

class SearchSuggestion {
  final String id;
  final String text;
  final String? category;

  SearchSuggestion({required this.id, required this.text, this.category});
}
