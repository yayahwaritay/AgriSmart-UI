import 'package:flutter/foundation.dart';

/// A short farming how-to video, with the engagement counters the API
/// tracks alongside it (likes, comments, views).
@immutable
class TutorialVideo {
  const TutorialVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.instructor,
    required this.instructorAvatarEmoji,
    required this.durationLabel,
    required this.views,
    required this.uploadedAt,
    required this.likeCount,
    required this.commentCount,
    this.isLiked = false,
  });

  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String thumbnailUrl;
  final String instructor;
  final String instructorAvatarEmoji;

  /// Pre-formatted runtime, e.g. "9:56" — the real duration is read from
  /// the player once the video loads.
  final String durationLabel;

  final int views;
  final DateTime uploadedAt;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  TutorialVideo copyWith({bool? isLiked, int? likeCount, int? commentCount}) {
    return TutorialVideo(
      id: id,
      title: title,
      description: description,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      instructor: instructor,
      instructorAvatarEmoji: instructorAvatarEmoji,
      durationLabel: durationLabel,
      views: views,
      uploadedAt: uploadedAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  String get viewsLabel {
    if (views >= 1000000) return '${(views / 1000000).toStringAsFixed(1)}M views';
    if (views >= 1000) return '${(views / 1000).toStringAsFixed(1)}K views';
    return '$views views';
  }

  // Deliberately no id-based == override: copyWith always returns a new
  // instance, and Riverpod's Provider.family relies on default (identity)
  // equality to detect that a video's like/comment counts actually changed.
}
