import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'post_model.dart';
import 'media_playback_coordinator.dart';

class PostMedia extends StatefulWidget {
  final Post post;
  final VoidCallback? onDoubleTapLike;
  final bool autoPlay;

  const PostMedia({
    super.key,
    required this.post,
    this.onDoubleTapLike,
    this.autoPlay = false,
  });

  @override
  State<PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends State<PostMedia> {
  VideoPlayerController? _vc;
  bool _muted = true;
  double _playbackSpeed = 1.0;
  final GlobalKey _mediaKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.post.mediaType == MediaType.video) {
      // Check if it's a local asset or network URL
      if (widget.post.mediaUrl.startsWith('assets/')) {
        _vc =
            VideoPlayerController.asset(widget.post.mediaUrl)
              ..setLooping(true)
              ..setVolume(_muted ? 0 : 1)
              ..initialize().then((_) {
                if (mounted) {
                  setState(() {});
                  if (widget.autoPlay) {
                    MediaPlaybackCoordinator.I.registerActive(_vc!);
                    _vc!.play();
                  }
                }
              });
      } else {
        _vc =
            VideoPlayerController.networkUrl(Uri.parse(widget.post.mediaUrl))
              ..setLooping(true)
              ..setVolume(_muted ? 0 : 1)
              ..initialize().then((_) {
                if (mounted) {
                  setState(() {});
                  if (widget.autoPlay) {
                    MediaPlaybackCoordinator.I.registerActive(_vc!);
                    _vc!.play();
                  }
                }
              });
      }
    }
  }

  @override
  void dispose() {
    _vc?.dispose();
    super.dispose();
  }

  void _toggleMute() {
    _muted = !_muted;
    _vc?.setVolume(_muted ? 0 : 1);
    setState(() {});
  }

  void _onLongPressStart(LongPressStartDetails d) {
    if (_vc == null || !_vc!.value.isInitialized) return;
    final box = _mediaKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(d.globalPosition);
    final fracX = (local.dx / box.size.width).clamp(0.0, 1.0);
    if (fracX <= 0.10 || fracX >= 0.90) {
      _playbackSpeed = 2.0;
      _vc!.setPlaybackSpeed(_playbackSpeed);
      if (!_vc!.value.isPlaying) {
        MediaPlaybackCoordinator.I.registerActive(_vc!);
        _vc!.play();
      }
    } else {
      _vc!.pause();
    }
  }

  void _onLongPressEnd(_) {
    if (_vc == null || !_vc!.value.isInitialized) return;
    _playbackSpeed = 1.0;
    _vc!.setPlaybackSpeed(_playbackSpeed);
    MediaPlaybackCoordinator.I.registerActive(_vc!);
    _vc!.play();
  }

  Widget _buildImageWidget() {
    // Check if it's a local asset or network URL
    if (widget.post.mediaUrl.startsWith('assets/')) {
      return Image.asset(
        widget.post.mediaUrl,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            ),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: widget.post.mediaUrl,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Container(
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorWidget:
            (context, url, error) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.error),
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.post.mediaType == MediaType.image) {
      return AspectRatio(
        aspectRatio: 4 / 5, // Fixed 4:5 for images
        child: _buildImageWidget(),
      );
    }

    final ready = _vc?.value.isInitialized ?? false;
    return Stack(
      key: _mediaKey,
      fit: StackFit.expand,
      children: [
        AspectRatio(
          aspectRatio:
              ready ? _vc!.value.aspectRatio : 9 / 16, // Fixed 9:16 for videos
          child:
              ready
                  ? VideoPlayer(_vc!)
                  : Container(
                    color: Colors.black12,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              if (_vc == null) return;
              if (_vc!.value.isPlaying) {
                MediaPlaybackCoordinator.I.pauseIfActive(_vc!);
              } else {
                MediaPlaybackCoordinator.I.registerActive(_vc!);
                _vc!.play();
              }
              setState(() {});
            },
            onDoubleTap: widget.onDoubleTapLike,
            onLongPressStart: _onLongPressStart,
            onLongPressEnd: _onLongPressEnd,
          ),
        ),
        if (ready) ...[
          if (!_vc!.value.isPlaying)
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                size: 64,
                color: Colors.white70,
              ),
            ),
          Positioned(
            right: 8,
            bottom: 8,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _muted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
