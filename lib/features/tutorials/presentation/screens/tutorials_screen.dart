import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/build_context_x.dart';
import '../../application/tutorial_providers.dart';
import '../widgets/video_feed_card.dart';

class TutorialsScreen extends ConsumerWidget {
  const TutorialsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.agriColors;
    final videos = ref.watch(tutorialVideosProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Video Tutorials', style: context.textTheme.headlineSmall),
                  const SizedBox(height: 2),
                  Text(
                    'Learn from agronomists and fellow farmers',
                    style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: videos.when(
                data: (items) => items.isEmpty
                    ? Center(
                        child: Text(
                          'No tutorials yet — check back soon.',
                          style: context.textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.refresh(tutorialVideosProvider.future),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                          itemCount: items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 16),
                          itemBuilder: (context, index) => VideoFeedCard(
                            video: items[index],
                            onTap: () => context.push('/tutorial', extra: items[index]),
                          ),
                        ),
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text('Could not load tutorials', style: TextStyle(color: colors.accent)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
