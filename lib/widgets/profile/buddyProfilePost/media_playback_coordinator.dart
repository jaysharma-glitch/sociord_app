import 'package:video_player/video_player.dart';

class MediaPlaybackCoordinator {
  static final MediaPlaybackCoordinator I = MediaPlaybackCoordinator._();
  MediaPlaybackCoordinator._();

  VideoPlayerController? _active;

  void registerActive(VideoPlayerController c) {
    if (_active == c) return;
    _active?.pause();
    _active = c;
  }

  void pauseIfActive(VideoPlayerController c) {
    if (_active == c) {
      _active?.pause();
      _active = null;
    }
  }

  void pauseAll() => _active?.pause();
}
