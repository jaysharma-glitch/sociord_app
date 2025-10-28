class ClipModel {
  final String id;
  final String imageUrl;
  final String title;
  final String rating;
  final int views;
  final int likes;
  final int comments;
  final String timeAgo;
  final bool isLandscape;

  const ClipModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.rating,
    required this.views,
    required this.likes,
    required this.comments,
    required this.timeAgo,
    required this.isLandscape,
  });
}
