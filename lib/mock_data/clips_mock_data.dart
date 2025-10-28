import 'package:sociord/models/clip_model.dart';
import 'package:sociord/utils/asset_path_constants.dart';

class ClipsMockData {
  static const List<ClipModel> landscapeClips = [
    ClipModel(
      id: 'landscape_1',
      imageUrl: kCreatorClip1,
      title: 'Lost in Paradise',
      rating: 'Excellent',
      views: 256000,
      likes: 15000,
      comments: 325,
      timeAgo: '30 days ago',
      isLandscape: true,
    ),
    ClipModel(
      id: 'landscape_2',
      imageUrl: kCreatorClip2,
      title: 'Waves and Trails',
      rating: 'Excellent',
      views: 2200000,
      likes: 4230,
      comments: 500000,
      timeAgo: '30 days ago',
      isLandscape: true,
    ),
  ];

  static const List<ClipModel> portraitClips = [
    ClipModel(
      id: 'portrait_1',
      imageUrl: kCreatorClip3, // Using 3.png as requested
      title: 'Lost in Paradise', // Data from screenshot
      rating: 'Excellent',
      views: 256000, // 256K
      likes: 15000,
      comments: 325,
      timeAgo: '30 days ago',
      isLandscape: false,
    ),
    ClipModel(
      id: 'portrait_2',
      imageUrl: kCreatorClip4,
      title: 'Waves and Trails', // Data from screenshot
      rating: 'Excellent',
      views: 2200000, // 2.2M
      likes: 4230,
      comments: 500000, // 500K
      timeAgo: '30 days ago',
      isLandscape: false,
    ),
    ClipModel(
      id: 'portrait_3',
      imageUrl: kCreatorClip5,
      title: 'Into the Wild', // Data from screenshot
      rating: 'Excellent',
      views: 1200000, // 1.2M
      likes: 15000,
      comments: 2300,
      timeAgo: '30 days ago',
      isLandscape: false,
    ),
    ClipModel(
      id: 'portrait_4',
      imageUrl: kCreatorClip6,
      title: 'A Journey of a Lifetime', // Data from screenshot
      rating: 'Nice',
      views: 300000000, // 300M
      likes: 280000, // 280K
      comments: 520,
      timeAgo: '29th June 2023',
      isLandscape: false,
    ),
  ];

  static List<ClipModel> getAllClips() {
    return [...landscapeClips, ...portraitClips];
  }

  static List<ClipModel> getClipsByOrientation(bool isLandscape) {
    return isLandscape ? landscapeClips : portraitClips;
  }
}
