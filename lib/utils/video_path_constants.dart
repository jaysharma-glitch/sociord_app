// Video path constants for local assets
class VideoPathConstants {
  static const String _basePath = 'assets/videos/buddy/';

  // Buddy videos
  static const List<String> buddyVideos = [
    '${_basePath}1.mp4',
    '${_basePath}2.mp4',
    '${_basePath}3.mp4',
    '${_basePath}4.mp4',
    '${_basePath}5.mp4',
    '${_basePath}6.mp4',
    '${_basePath}7.mp4',
    '${_basePath}8.mp4',
  ];

  // Get a random video from the buddy videos
  static String getRandomBuddyVideo() {
    final random = DateTime.now().millisecondsSinceEpoch % buddyVideos.length;
    return buddyVideos[random];
  }

  // Get a specific video by index (0-7)
  static String getBuddyVideo(int index) {
    if (index >= 0 && index < buddyVideos.length) {
      return buddyVideos[index];
    }
    return buddyVideos[0]; // fallback to first video
  }
}
