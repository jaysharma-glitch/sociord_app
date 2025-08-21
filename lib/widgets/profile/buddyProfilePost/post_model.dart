class Post {
  final String id;
  final String userId;
  final DateTime createdAt;
  final String mediaUrl; // image/video thumbnail for now
  final String caption;

  const Post({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.mediaUrl,
    required this.caption,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Post && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Post{id: $id, userId: $userId, createdAt: $createdAt, mediaUrl: $mediaUrl, caption: $caption}';
  }
}
