import '../entities/tutorial_video.dart';
import '../entities/video_comment.dart';

/// Read/write side of the video tutorials feature. Talks to whatever backs
/// the "/tutorials" API — likes and comments round-trip through here so a
/// real HTTP-backed implementation can drop in without UI changes.
abstract interface class TutorialRepository {
  Future<List<TutorialVideo>> fetchVideos();

  Future<List<VideoComment>> fetchComments(String videoId);

  /// Persists the like state for [videoId] and returns the server's
  /// authoritative like count.
  Future<int> setLiked(String videoId, bool liked);

  Future<VideoComment> postComment(String videoId, String text);
}
