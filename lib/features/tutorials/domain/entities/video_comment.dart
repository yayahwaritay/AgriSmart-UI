import 'package:flutter/foundation.dart';

/// One comment left under a [TutorialVideo].
@immutable
class VideoComment {
  const VideoComment({
    required this.id,
    required this.videoId,
    required this.author,
    required this.avatarEmoji,
    required this.text,
    required this.postedAt,
  });

  final String id;
  final String videoId;
  final String author;
  final String avatarEmoji;
  final String text;
  final DateTime postedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is VideoComment && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
