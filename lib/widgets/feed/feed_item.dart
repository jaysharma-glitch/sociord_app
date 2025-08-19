class FeedItem {
  final String imagePath;
  final String title; // "username" for buddy, "highlightName" for highlight
  final String caption;
  final bool isVideo;
  final int duration;
  final String? profileImage; // For buddy posts
  final String? userName; // For buddy posts

  const FeedItem({
    required this.imagePath,
    required this.title,
    required this.caption,
    this.isVideo = false,
    this.duration = 15,
    this.profileImage,
    this.userName,
  });

  factory FeedItem.fromMap(Map<String, dynamic> map) {
    return FeedItem(
      imagePath: map['imagePath'] ?? '',
      title: map['title'] ?? map['username'] ?? map['highlightName'] ?? '',
      caption: map['caption'] ?? '',
      isVideo: map['isVideo'] ?? false,
      duration: map['duration'] ?? 15,
      profileImage: map['profileImage'],
      userName: map['username'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'title': title,
      'caption': caption,
      'isVideo': isVideo,
      'duration': duration,
      'profileImage': profileImage,
      'username': userName,
    };
  }
}
