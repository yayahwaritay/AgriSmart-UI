import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/utils/date_x.dart';
import '../../application/tutorial_providers.dart';
import '../../domain/entities/tutorial_video.dart';
import '../widgets/comment_composer.dart';
import '../widgets/comment_tile.dart';
import '../widgets/tutorial_video_player.dart';

class VideoDetailScreen extends ConsumerWidget {
  const VideoDetailScreen({super.key, required this.initialVideo});

  final TutorialVideo initialVideo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;
    // Falls back to the video passed via route `extra` until the live list
    // has loaded, then tracks it so likes/comment counts stay in sync.
    final video = ref.watch(tutorialVideoProvider(initialVideo.id)) ?? initialVideo;
    final comments = ref.watch(videoCommentsProvider(video.id));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Tutorial', style: context.textTheme.titleMedium?.copyWith(color: Colors.white)),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            TutorialVideoPlayer(videoUrl: video.videoUrl),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(color: colors.surface),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    Text(video.title, style: context.textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(
                      '${video.viewsLabel} · ${video.uploadedAt.toRelativeLabel()}',
                      style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _LikeButton(video: video),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: colors.primary.withValues(alpha: 0.14),
                          child: Text(video.instructorAvatarEmoji, style: const TextStyle(fontSize: 17)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            video.instructor,
                            style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: colors.divider),
                    const SizedBox(height: 4),
                    Text(video.description, style: context.textTheme.bodySmall),
                    const SizedBox(height: 16),
                    Divider(color: colors.divider),
                    const SizedBox(height: 8),
                    Text('${video.commentCount} Comments', style: context.textTheme.titleSmall),
                    const SizedBox(height: 12),
                    CommentComposer(
                      onSubmit: (text) => ref.read(localCommentsProvider.notifier).post(video.id, text),
                    ),
                    const SizedBox(height: 4),
                    comments.when(
                      data: (items) => items.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'No comments yet — be the first to share your thoughts.',
                                style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                              ),
                            )
                          : Column(children: [for (final c in items) CommentTile(comment: c)]),
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text('Could not load comments', style: TextStyle(color: colors.accent)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LikeButton extends ConsumerWidget {
  const _LikeButton({required this.video});

  final TutorialVideo video;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;

    return Material(
      color: video.isLiked ? colors.primary.withValues(alpha: 0.16) : colors.textSecondary.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => ref.read(tutorialVideosProvider.notifier).toggleLike(video.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                video.isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                size: 18,
                color: video.isLiked ? colors.primary : colors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                '${video.likeCount}',
                style: context.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: video.isLiked ? colors.primary : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
