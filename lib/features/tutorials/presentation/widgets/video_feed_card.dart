import 'package:flutter/material.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/utils/date_x.dart';
import '../../../../core/widgets/neu_card.dart';
import '../../domain/entities/tutorial_video.dart';

/// Feed tile for one tutorial: thumbnail with duration badge, title,
/// instructor, and the like/comment counters — the YouTube-style list row.
class VideoFeedCard extends StatelessWidget {
  const VideoFeedCard({super.key, required this.video, required this.onTap});

  final TutorialVideo video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return NeuCard(
      padding: const EdgeInsets.all(10),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) =>
                        progress == null ? child : ColoredBox(color: colors.surface, child: child),
                    errorBuilder: (context, error, stack) => ColoredBox(
                      color: colors.surface,
                      child: Icon(Icons.image_not_supported_rounded, color: colors.textSecondary),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.45)],
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 46),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: _DurationBadge(label: video.durationLabel),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: colors.primary.withValues(alpha: 0.14),
                  child: Text(video.instructorAvatarEmoji, style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${video.instructor} · ${video.viewsLabel} · ${video.uploadedAt.toRelativeLabel()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.labelSmall?.copyWith(color: colors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            video.isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                            size: 14,
                            color: video.isLiked ? colors.primary : colors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text('${video.likeCount}', style: context.textTheme.labelSmall?.copyWith(color: colors.textSecondary)),
                          const SizedBox(width: 14),
                          Icon(Icons.mode_comment_outlined, size: 14, color: colors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${video.commentCount}',
                            style: context.textTheme.labelSmall?.copyWith(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationBadge extends StatelessWidget {
  const _DurationBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
