import 'package:sociord/models/collection_model.dart';
import 'package:sociord/models/clip_model.dart';
import 'package:sociord/utils/asset_path_constants.dart';

class CollectionsMockData {
  static const List<ClipModel> romanticDiningPosts = [
    ClipModel(
      id: 'romantic_1',
      imageUrl: kCreatorCollection1, // Using creator-collection images
      title: 'Pasta with Wine',
      rating: 'Nice',
      views: 150000,
      likes: 8500,
      comments: 420,
      timeAgo: '2 days ago',
      isLandscape: false,
    ),
    ClipModel(
      id: 'romantic_2',
      imageUrl: kCreatorCollection2,
      title: 'Spaghetti Bowl',
      rating: 'Nice',
      views: 89000,
      likes: 5200,
      comments: 280,
      timeAgo: '1 day ago',
      isLandscape: false,
    ),
    ClipModel(
      id: 'romantic_3',
      imageUrl: kCreatorCollection3,
      title: 'Golden Pancakes',
      rating: 'Nice',
      views: 120000,
      likes: 7200,
      comments: 350,
      timeAgo: '3 days ago',
      isLandscape: false,
    ),
  ];

  static const List<ClipModel> ancientRuinsPosts = [
    ClipModel(
      id: 'ruins_1',
      imageUrl: kCreatorCollection7,
      title: 'Hiking Trail',
      rating: 'Excellent',
      views: 380000,
      likes: 24000,
      comments: 950,
      timeAgo: '1 week ago',
      isLandscape: false,
    ),
    ClipModel(
      id: 'ruins_2',
      imageUrl: kCreatorCollection8,
      title: 'Snow Mountain',
      rating: 'Excellent',
      views: 520000,
      likes: 32000,
      comments: 1400,
      timeAgo: '3 weeks ago',
      isLandscape: false,
    ),
  ];

  static const List<ClipModel> trekkingPosts = [
    ClipModel(
      id: 'trek_1',
      imageUrl: kCreatorCollection4,
      title: 'Aerial Ruins',
      rating: 'Good',
      views: 250000,
      likes: 15000,
      comments: 800,
      timeAgo: '1 week ago',
      isLandscape: false,
    ),
    ClipModel(
      id: 'trek_2',
      imageUrl: kCreatorCollection5,
      title: 'Stone Columns',
      rating: 'Good',
      views: 180000,
      likes: 11000,
      comments: 600,
      timeAgo: '5 days ago',
      isLandscape: false,
    ),
    ClipModel(
      id: 'trek_3',
      imageUrl: kCreatorCollection6,
      title: 'Hot Springs',
      rating: 'Excellent',
      views: 450000,
      likes: 28000,
      comments: 1200,
      timeAgo: '2 weeks ago',
      isLandscape: false,
    ),
  ];

  static const List<ClipModel> paraglidingPosts = [
    ClipModel(
      id: 'para_1',
      imageUrl: kCreatorCollection9,
      title: 'Mountain Paragliding',
      rating: 'Excellent',
      views: 680000,
      likes: 42000,
      comments: 1800,
      timeAgo: '1 month ago',
      isLandscape: false,
    ),
    ClipModel(
      id: 'para_2',
      imageUrl: kCreatorCollection10,
      title: 'Ocean Hang Gliding',
      rating: 'Excellent',
      views: 750000,
      likes: 48000,
      comments: 2100,
      timeAgo: '2 weeks ago',
      isLandscape: false,
    ),
  ];

  // Portrait collections (using images 1-6)
  static const List<CollectionModel> portraitCollections = [
    CollectionModel(
      id: 'romantic_dining',
      title: 'Romantic Dining at it\'s best - Tuscany',
      rating: 'Nice',
      posts: romanticDiningPosts,
    ),
    CollectionModel(
      id: 'trekking',
      title: 'Treks you cannot miss',
      rating: 'Excellent',
      posts: trekkingPosts,
    ),
  ];

  // Landscape collections (using images 7-10)
  static const List<CollectionModel> landscapeCollections = [
    CollectionModel(
      id: 'ancient_ruins',
      title: 'Exploring Ancient Ruins',
      rating: 'Good',
      posts: ancientRuinsPosts,
    ),
    CollectionModel(
      id: 'paragliding',
      title: 'Paragliding',
      rating: 'Excellent',
      posts: paraglidingPosts,
    ),
  ];

  // All collections combined
  static const List<CollectionModel> collections = [
    ...portraitCollections,
    ...landscapeCollections,
  ];
}
