class BuddyRequest {
  final String id;
  final String username;
  final String message;
  final String profileImage;

  BuddyRequest({
    required this.id,
    required this.username,
    required this.message,
    required this.profileImage,
  });
}

class BuddySuggestion {
  final String id;
  final String username;
  final String demographics;
  final String location;
  final String profileImage;

  BuddySuggestion({
    required this.id,
    required this.username,
    required this.demographics,
    required this.location,
    required this.profileImage,
  });
}
