import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';

// Mock rating entry
class MockRating {
  final String userImage;
  final String userName;
  final String userId;
  final int rating;

  MockRating({
    required this.userImage,
    required this.userName,
    required this.userId,
    required this.rating,
  });
}

// Example mock data (add more as needed)
final List<MockRating> mockRatings = [
  MockRating(
    userImage: 'assets/images/creator/1.jpeg',
    userName: 'carlosinmotion',
    userId: '1',
    rating: 4,
  ),
  MockRating(
    userImage: 'assets/images/creator/2.png',
    userName: 'cosmic.route07',
    userId: '2',
    rating: 3,
  ),
  MockRating(
    userImage: 'assets/images/creator/3.png',
    userName: 'noahbright_11',
    userId: '3',
    rating: 4,
  ),
  MockRating(
    userImage: 'assets/images/creator/4.png',
    userName: 'rohanvibe',
    userId: '4',
    rating: 5,
  ),
  MockRating(
    userImage: 'assets/images/creator/5.png',
    userName: 'priya.vision',
    userId: '5',
    rating: 5,
  ),
  MockRating(
    userImage: 'assets/images/creator/6.png',
    userName: 'alex.orbit',
    userId: '6',
    rating: 4,
  ),
  MockRating(
    userImage: 'assets/images/creator/7.png',
    userName: 'devika.wave_25',
    userId: '7',
    rating: 4,
  ),
  MockRating(
    userImage: 'assets/images/creator/8.png',
    userName: 'grace.legacy',
    userId: '8',
    rating: 5,
  ),
  MockRating(
    userImage: 'assets/images/creator/3.png',
    userName: 'nirav_voyager',
    userId: '9',
    rating: 4,
  ),
  MockRating(
    userImage: 'assets/images/creator/4.png',
    userName: 'lavender.echo',
    userId: '10',
    rating: 4,
  ),
  MockRating(
    userImage: 'assets/images/creator/5.png',
    userName: 'roop3riva',
    userId: '11',
    rating: 4,
  ),
  MockRating(
    userImage: 'assets/images/creator/6.png',
    userName: 'liam.zone',
    userId: '12',
    rating: 4,
  ),
  MockRating(
    userImage: 'assets/images/creator/7.png',
    userName: 'leahcannelly',
    userId: '13',
    rating: 3,
  ),
  MockRating(
    userImage: 'assets/images/creator/8.png',
    userName: 'morrisons',
    userId: '14',
    rating: 5,
  ),
  MockRating(
    userImage: 'assets/images/creator/1.jpeg',
    userName: 'ishani.md',
    userId: '15',
    rating: 4,
  ),
  MockRating(
    userImage: 'assets/images/creator/2.png',
    userName: 'mehfilwithadil',
    userId: '16',
    rating: 4,
  ),
  MockRating(
    userImage: 'assets/images/creator/3.png',
    userName: 'rajan_chowksi',
    userId: '17',
    rating: 5,
  ),
  // Add more for testing infinite scroll
];

// Rating keyword and color mapping
class RatingDisplay {
  final String keyword;
  final Color color;
  const RatingDisplay(this.keyword, this.color);
}

RatingDisplay getRatingDisplay(int rating) {
  switch (rating) {
    case 5:
      return RatingDisplay('Rated Excellent', kAppPurple); // Purple
    case 4:
      return RatingDisplay('Rated Good', kAppYellow); // Gold
    case 3:
      return RatingDisplay('Rated Nice', kAppTeal); // Teal
    case 2:
      return RatingDisplay('Average', Color(0xFF7F8385)); // Grey
    case 1:
      return RatingDisplay('Below Average', Color(0xFF7F8385)); // Grey
    default:
      return RatingDisplay('', Color(0xFF7F8385));
  }
}

// Filter ratings for display (public list)
List<MockRating> filterRatingsForDisplay(
  List<MockRating> ratings,
  String currentUserId,
) {
  // Only show 3-5 star ratings, except for current user
  return ratings
      .where((r) => r.rating >= 3 || r.userId == currentUserId)
      .toList();
}

// Simulate infinite scroll (fetch next batch)
Future<List<MockRating>> fetchRatingsBatch(
  int start,
  int batchSize,
  String currentUserId, {
  String? search,
}) async {
  await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
  List<MockRating> filtered = mockRatings;
  if (search != null && search.length > 2) {
    filtered =
        filtered
            .where(
              (r) => r.userName.toLowerCase().contains(search.toLowerCase()),
            )
            .toList();
  }
  filtered = filterRatingsForDisplay(filtered, currentUserId);
  int end = (start + batchSize).clamp(0, filtered.length);
  if (start >= filtered.length) return [];
  return filtered.sublist(start, end);
}
