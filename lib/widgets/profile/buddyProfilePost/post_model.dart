enum MediaType { image, video }

class Post {
  final String id;
  final String userId;
  final DateTime createdAt;
  final MediaType mediaType;
  final String mediaUrl;
  final String? thumbnailUrl;
  final double? aspectRatio;
  final Duration? duration;
  final String caption;
  final bool liked;
  final int likeCount;

  const Post({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.mediaType,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.aspectRatio,
    this.duration,
    required this.caption,
    this.liked = false,
    this.likeCount = 0,
  });

  Post copyWith({bool? liked, int? likeCount}) => Post(
    id: id,
    userId: userId,
    createdAt: createdAt,
    mediaType: mediaType,
    mediaUrl: mediaUrl,
    thumbnailUrl: thumbnailUrl,
    aspectRatio: aspectRatio,
    duration: duration,
    caption: caption,
    liked: liked ?? this.liked,
    likeCount: likeCount ?? this.likeCount,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Post && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Post{id: $id, userId: $userId, createdAt: $createdAt, mediaType: $mediaType, mediaUrl: $mediaUrl, caption: $caption}';
  }
}
