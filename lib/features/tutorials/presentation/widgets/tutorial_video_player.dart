import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/build_context_x.dart';

/// Owns the [VideoPlayerController]/[ChewieController] lifecycle for one
/// video URL and renders a 16:9 player with standard scrubber controls.
class TutorialVideoPlayer extends StatefulWidget {
  const TutorialVideoPlayer({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<TutorialVideoPlayer> createState() => _TutorialVideoPlayerState();
}

class _TutorialVideoPlayerState extends State<TutorialVideoPlayer> {
  late final VideoPlayerController _videoController;
  ChewieController? _chewieController;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _videoController.initialize().then((_) {
      if (!mounted) return;
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: true,
          looping: false,
          aspectRatio: _videoController.value.aspectRatio,
        );
      });
    }).catchError((Object e) {
      if (mounted) setState(() => _error = e);
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ColoredBox(
        color: Colors.black,
        child: _error != null
            ? Center(
                child: Text('Could not load this video', style: TextStyle(color: colors.onPrimary)),
              )
            : _chewieController == null
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : Chewie(controller: _chewieController!),
      ),
    );
  }
}
