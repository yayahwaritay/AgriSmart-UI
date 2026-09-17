import '../../../../core/network/api_client.dart';
import '../../domain/entities/tutorial_video.dart';
import '../../domain/entities/video_comment.dart';
import '../../domain/repositories/tutorial_repository.dart';

/// API-backed tutorials repository — see `/tutorials` in README.mobile.md.
/// `VideoCommentDto` has no avatar, so comments get a fixed fallback emoji.
class HttpTutorialRepository implements TutorialRepository {
  HttpTutorialRepository(this._client);

  final ApiClient _client;

  static const _fallbackAvatar = '🙂';

  TutorialVideo _videoFromJson(Map<String, dynamic> json) {
    return TutorialVideo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      instructor: json['instructor'] as String,
      instructorAvatarEmoji: json['instructorAvatarEmoji'] as String,
      durationLabel: json['durationLabel'] as String,
      views: json['views'] as int,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      likeCount: json['likeCount'] as int,
      commentCount: json['commentCount'] as int,
      isLiked: json['isLiked'] as bool? ?? false,
    );
  }

  VideoComment _commentFromJson(Map<String, dynamic> json) {
    return VideoComment(
      id: json['id'] as String,
      videoId: json['videoId'] as String,
      author: json['authorName'] as String,
      avatarEmoji: _fallbackAvatar,
      text: json['text'] as String,
      postedAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  Future<List<TutorialVideo>> fetchVideos() async {
    final json = await _client.get('/tutorials/videos') as List<dynamic>;
    return json.map((e) => _videoFromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<VideoComment>> fetchComments(String videoId) async {
    final json = await _client.get('/tutorials/videos/$videoId/comments') as List<dynamic>;
    return json.map((e) => _commentFromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<int> setLiked(String videoId, bool liked) async {
    // Response shape isn't pinned down by the README beyond "the server's
    // authoritative like count" — read just that field so this doesn't
    // break if the endpoint returns a bare `{likeCount}` rather than a
    // full video DTO.
    final json = await _client.post('/tutorials/videos/$videoId/like', body: {'liked': liked});
    return (json as Map<String, dynamic>)['likeCount'] as int;
  }

  @override
  Future<VideoComment> postComment(String videoId, String text) async {
    final json = await _client.post('/tutorials/videos/$videoId/comments', body: {'text': text});
    return _commentFromJson(json as Map<String, dynamic>);
  }
}
