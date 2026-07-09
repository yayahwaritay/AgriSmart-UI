import 'package:flutter/material.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../../../core/utils/date_x.dart';
import '../../domain/entities/video_comment.dart';

class CommentTile extends StatelessWidget {
  const CommentTile({super.key, required this.comment});

  final VideoComment comment;

  @override
  Widget build(BuildContext context) {
    final colors = context.agriColors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: colors.primary.withValues(alpha: 0.14),
            child: Text(comment.avatarEmoji, style: const TextStyle(fontSize: 15)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.author, style: context.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text(
                      comment.postedAt.toRelativeLabel(),
                      style: context.textTheme.labelSmall?.copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(comment.text, style: context.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
