import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/dummy_tutorial_repository.dart';
import '../domain/entities/tutorial_video.dart';
import '../domain/entities/video_comment.dart';
import '../domain/repositories/tutorial_repository.dart';

final tutorialRepositoryProvider = Provider<TutorialRepository>((ref) {
  return DummyTutorialRepository();
});

class TutorialVideoList extends AsyncNotifier<List<TutorialVideo>> {
  @override
  Future<List<TutorialVideo>> build() {
    return ref.watch(tutorialRepositoryProvider).fetchVideos();
  }

  /// Flips the like state for [videoId] optimistically, then reconciles
  /// with the count the "server" confirms — reverting if that call fails.
  Future<void> toggleLike(String videoId) async {
    final videos = state.value;
    if (videos == null) return;
    final index = videos.indexWhere((v) => v.id == videoId);
    if (index == -1) return;

    final previous = videos[index];
    final optimistic = previous.copyWith(
      isLiked: !previous.isLiked,
      likeCount: previous.likeCount + (previous.isLiked ? -1 : 1),
    );
    state = AsyncData([...videos]..[index] = optimistic);

    try {
      final confirmedCount = await ref.read(tutorialRepositoryProvider).setLiked(videoId, optimistic.isLiked);
      final current = state.value;
      if (current == null) return;
      final i = current.indexWhere((v) => v.id == videoId);
      if (i == -1) return;
      state = AsyncData([...current]..[i] = current[i].copyWith(likeCount: confirmedCount));
    } catch (_) {
      final current = state.value;
      if (current == null) return;
      final i = current.indexWhere((v) => v.id == videoId);
      if (i == -1) return;
      state = AsyncData([...current]..[i] = previous);
    }
  }

  void bumpCommentCount(String videoId) {
    final videos = state.value;
    if (videos == null) return;
    state = AsyncData([
      for (final v in videos) v.id == videoId ? v.copyWith(commentCount: v.commentCount + 1) : v,
    ]);
  }
}

final tutorialVideosProvider = AsyncNotifierProvider<TutorialVideoList, List<TutorialVideo>>(
  TutorialVideoList.new,
);

/// Live view of one video by id, falling back to whatever was passed via
/// route `extra` until the list has loaded.
final tutorialVideoProvider = Provider.family<TutorialVideo?, String>((ref, videoId) {
  final videos = ref.watch(tutorialVideosProvider).value;
  if (videos == null) return null;
  for (final video in videos) {
    if (video.id == videoId) return video;
  }
  return null;
});

final _fetchedCommentsProvider = FutureProvider.family<List<VideoComment>, String>((ref, videoId) {
  return ref.watch(tutorialRepositoryProvider).fetchComments(videoId);
});

/// Comments posted this session, kept apart from [_fetchedCommentsProvider]
/// so a refetch never drops what the user just typed — mirrors how the
/// marketplace cart is layered on top of the fetched catalogue.
class LocalComments extends Notifier<Map<String, List<VideoComment>>> {
  @override
  Map<String, List<VideoComment>> build() => const {};

  Future<void> post(String videoId, String text) async {
    final comment = await ref.read(tutorialRepositoryProvider).postComment(videoId, text);
    final existing = state[videoId] ?? const [];
    state = {...state, videoId: [comment, ...existing]};
    ref.read(tutorialVideosProvider.notifier).bumpCommentCount(videoId);
  }
}

final localCommentsProvider = NotifierProvider<LocalComments, Map<String, List<VideoComment>>>(
  LocalComments.new,
);

final videoCommentsProvider = Provider.family<AsyncValue<List<VideoComment>>, String>((ref, videoId) {
  final fetched = ref.watch(_fetchedCommentsProvider(videoId));
  final local = ref.watch(localCommentsProvider)[videoId] ?? const [];
  return fetched.whenData((items) => [...local, ...items]);
});
