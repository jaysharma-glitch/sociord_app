enum CommentType { text, gif }

class CommentModel {
  final String profile;
  final String username;
  final String timeAgo;
  final String? text;
  final String? gifUrl;
  final int likes;
  final List<CommentModel> replies;
  final CommentType type;

  CommentModel({
    required this.profile,
    required this.username,
    required this.timeAgo,
    this.text,
    this.gifUrl,
    required this.likes,
    this.replies = const [],
    required this.type,
  });
}
