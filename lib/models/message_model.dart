class MessageItem {
  final String username;
  final String lastMessage;
  final String timestamp;
  final String profileImage;
  final bool isOnline;
  final bool isUnread;
  final String?
  relationshipLabel; // For Creator tab: "Subscriber", "Follower", "Following", "Subscribed"

  MessageItem({
    required this.username,
    required this.lastMessage,
    required this.timestamp,
    required this.profileImage,
    this.isOnline = false,
    this.isUnread = false,
    this.relationshipLabel,
  });
}
