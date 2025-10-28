class MockShareUser {
  final String userImage;
  final String userName;
  final String userId;

  MockShareUser({
    required this.userImage,
    required this.userName,
    required this.userId,
  });
}

final List<MockShareUser> mockShareUsers = [
  MockShareUser(
    userImage: 'assets/images/creator/1.jpeg',
    userName: 'grace.legacy',
    userId: '1',
  ),
  MockShareUser(
    userImage: 'assets/images/creator/2.png',
    userName: 'nirav_voyager',
    userId: '2',
  ),
  MockShareUser(
    userImage: 'assets/images/creator/3.png',
    userName: 'lavender.echo',
    userId: '3',
  ),
  MockShareUser(
    userImage: 'assets/images/creator/4.png',
    userName: 'roop3riva',
    userId: '4',
  ),
  MockShareUser(
    userImage: 'assets/images/creator/5.png',
    userName: 'liam.zone',
    userId: '5',
  ),
  MockShareUser(
    userImage: 'assets/images/creator/6.png',
    userName: 'leahcannelly',
    userId: '6',
  ),
  MockShareUser(
    userImage: 'assets/images/creator/7.png',
    userName: 'nushkasworld',
    userId: '7',
  ),
  MockShareUser(
    userImage: 'assets/images/creator/8.png',
    userName: 'ramandshyam',
    userId: '8',
  ),
  MockShareUser(
    userImage: 'assets/images/profileImage.png',
    userName: 'ishani.md',
    userId: '9',
  ),
  MockShareUser(
    userImage: 'assets/images/creator/2.png',
    userName: 'meghna.singh',
    userId: '10',
  ),
  MockShareUser(
    userImage: 'assets/images/creator/3.png',
    userName: 'arjun.k',
    userId: '11',
  ),
  MockShareUser(
    userImage: 'assets/images/creator/4.png',
    userName: 'sara.fern',
    userId: '12',
  ),
  MockShareUser(
    userImage: 'assets/images/creator/5.png',
    userName: 'theo.james',
    userId: '13',
  ),
  MockShareUser(
    userImage: 'assets/images/creator/6.png',
    userName: 'mira.roy',
    userId: '14',
  ),
  MockShareUser(
    userImage: 'assets/images/creator/7.png',
    userName: 'vicky.g',
    userId: '15',
  ),
  MockShareUser(
    userImage: 'assets/images/creator/8.png',
    userName: 'alex.turner',
    userId: '16',
  ),
  MockShareUser(
    userImage: 'assets/images/profileImage.png',
    userName: 'priya.vision',
    userId: '17',
  ),
  MockShareUser(
    userImage: 'assets/images/creator/1.jpeg',
    userName: 'darius_nova',
    userId: '18',
  ),
];

Future<List<MockShareUser>> fetchShareUsersBatch(
  int start,
  int batchSize, {
  String? search,
}) async {
  await Future.delayed(Duration(milliseconds: 500)); // Simulate network delay
  List<MockShareUser> filtered = mockShareUsers;
  if (search != null && search.length > 2) {
    filtered =
        filtered
            .where(
              (u) => u.userName.toLowerCase().contains(search.toLowerCase()),
            )
            .toList();
  }
  int end = (start + batchSize).clamp(0, filtered.length);
  if (start >= filtered.length) return [];
  return filtered.sublist(start, end);
}
