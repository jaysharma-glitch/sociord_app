enum CommentType { text, gif }

class CommentModel {
  final String profile;
  final String username;
  final String timeAgo;
  final String? text;
  final String? gifUrl;
  List<CommentModel> replies;
  int likes;
  bool likedByMe;
  final CommentType type;

  CommentModel({
    required this.profile,
    required this.username,
    required this.timeAgo,
    this.text,
    this.gifUrl,
    this.likes = 0,
    this.likedByMe = false,
    List<CommentModel>? replies,
    required this.type,
  }) : replies = replies ?? [];

  CommentModel copyWith({
    String? profile,
    String? username,
    String? timeAgo,
    String? text,
    String? gifUrl,
    int? likes,
    bool? likedByMe,
    List<CommentModel>? replies,
    CommentType? type,
  }) {
    return CommentModel(
      profile: profile ?? this.profile,
      username: username ?? this.username,
      timeAgo: timeAgo ?? this.timeAgo,
      text: text ?? this.text,
      gifUrl: gifUrl ?? this.gifUrl,
      likes: likes ?? this.likes,
      likedByMe: likedByMe ?? this.likedByMe,
      replies: replies ?? List<CommentModel>.from(this.replies),
      type: type ?? this.type,
    );
  }
}
