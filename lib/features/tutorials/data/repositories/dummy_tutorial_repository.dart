import '../../domain/entities/tutorial_video.dart';
import '../../domain/entities/video_comment.dart';
import '../../domain/repositories/tutorial_repository.dart';

/// Seeded, in-memory stand-in for the "/tutorials" API — mimics network
/// latency and mutates its own store on like/comment so the screens behave
/// exactly as they will once a real HTTP client replaces this class.
class DummyTutorialRepository implements TutorialRepository {
  static final List<TutorialVideo> _videos = [
    TutorialVideo(
      id: 'vid-early-blight',
      title: 'Spotting Early Blight on Tomato Leaves Before It Spreads',
      description:
          'A field walkthrough on identifying the tell-tale concentric leaf spots of early '
          'blight, and the first three treatment steps to stop it spreading through the row.',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      thumbnailUrl: 'https://picsum.photos/seed/vid-early-blight/640/360',
      instructor: 'Dr. Ade Fashola',
      instructorAvatarEmoji: '🧑‍🌾',
      durationLabel: '0:08',
      views: 18400,
      uploadedAt: DateTime.now().subtract(const Duration(days: 6)),
      likeCount: 812,
      commentCount: 3,
    ),
    TutorialVideo(
      id: 'vid-maize-spacing',
      title: 'Correct Row Spacing for Hybrid Maize',
      description:
          'Why 75cm x 25cm spacing consistently outperforms tighter planting for hybrid maize '
          'varieties, with a simple string-and-peg method you can use without a measuring wheel.',
      videoUrl: 'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4',
      thumbnailUrl: 'https://picsum.photos/seed/vid-maize-spacing/640/360',
      instructor: 'Chidinma Okoro',
      instructorAvatarEmoji: '👩‍🌾',
      durationLabel: '0:05',
      views: 9200,
      uploadedAt: DateTime.now().subtract(const Duration(days: 14)),
      likeCount: 431,
      commentCount: 2,
    ),
    TutorialVideo(
      id: 'vid-composting',
      title: 'Organic Composting for Smallholder Farms',
      description:
          'Turning crop residue and kitchen waste into usable compost in six weeks, using a '
          'three-bin rotation that needs no imported inputs.',
      videoUrl: 'https://www.w3schools.com/html/mov_bbb.mp4',
      thumbnailUrl: 'https://picsum.photos/seed/vid-composting/640/360',
      instructor: 'Musa Ibrahim',
      instructorAvatarEmoji: '🧑‍🌾',
      durationLabel: '0:10',
      views: 26100,
      uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
      likeCount: 1204,
      commentCount: 2,
    ),
    TutorialVideo(
      id: 'vid-nitrogen-deficiency',
      title: 'Diagnosing Nitrogen Deficiency by Leaf Colour',
      description:
          'The yellowing pattern that separates nitrogen deficiency from natural leaf ageing, '
          'and how quickly a urea top-dressing should show visible recovery.',
      videoUrl: 'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4',
      thumbnailUrl: 'https://picsum.photos/seed/vid-nitrogen-deficiency/640/360',
      instructor: 'Dr. Ade Fashola',
      instructorAvatarEmoji: '🧑‍🌾',
      durationLabel: '0:10',
      views: 14700,
      uploadedAt: DateTime.now().subtract(const Duration(days: 21)),
      likeCount: 655,
      commentCount: 1,
    ),
    TutorialVideo(
      id: 'vid-drip-irrigation',
      title: 'Setting Up a Low-Cost Drip Irrigation Line',
      description:
          'A half-hectare drip layout built from a header tank, mainline, and punched lateral '
          'tape, with the pressure checks to run before you plant.',
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      thumbnailUrl: 'https://picsum.photos/seed/vid-drip-irrigation/640/360',
      instructor: 'Grace Adeyemi',
      instructorAvatarEmoji: '👩‍🌾',
      durationLabel: '0:08',
      views: 7300,
      uploadedAt: DateTime.now().subtract(const Duration(days: 30)),
      likeCount: 298,
      commentCount: 1,
    ),
    TutorialVideo(
      id: 'vid-grain-storage',
      title: 'Post-Harvest Storage That Cuts Grain Losses',
      description:
          'Hermetic bagging versus traditional cribs for maize and rice — moisture targets, '
          'weevil prevention, and how long each method safely holds grain.',
      videoUrl: 'https://interactive-examples.mdn.mozilla.net/media/cc0-videos/flower.mp4',
      thumbnailUrl: 'https://picsum.photos/seed/vid-grain-storage/640/360',
      instructor: 'Musa Ibrahim',
      instructorAvatarEmoji: '🧑‍🌾',
      durationLabel: '0:05',
      views: 11900,
      uploadedAt: DateTime.now().subtract(const Duration(days: 45)),
      likeCount: 520,
      commentCount: 0,
    ),
  ];

  static final Map<String, List<VideoComment>> _comments = {
    'vid-early-blight': [
      VideoComment(
        id: 'c1',
        videoId: 'vid-early-blight',
        author: 'Tunde A.',
        avatarEmoji: '👨‍🌾',
        text: 'Copper fungicide worked for me after watching this, thank you!',
        postedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      VideoComment(
        id: 'c2',
        videoId: 'vid-early-blight',
        author: 'Blessing O.',
        avatarEmoji: '👩‍🌾',
        text: 'Does this also apply to potato leaves or just tomato?',
        postedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      VideoComment(
        id: 'c3',
        videoId: 'vid-early-blight',
        author: 'Dr. Ade Fashola',
        avatarEmoji: '🧑‍🌾',
        text: 'Blessing — yes, potato shows the same pattern, treat it the same way.',
        postedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ],
    'vid-maize-spacing': [
      VideoComment(
        id: 'c4',
        videoId: 'vid-maize-spacing',
        author: 'Ibrahim S.',
        avatarEmoji: '👨‍🌾',
        text: 'The peg-and-string trick saved me so much time this planting season.',
        postedAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      VideoComment(
        id: 'c5',
        videoId: 'vid-maize-spacing',
        author: 'Ngozi E.',
        avatarEmoji: '👩‍🌾',
        text: 'Would this spacing still work on sloped land?',
        postedAt: DateTime.now().subtract(const Duration(days: 9)),
      ),
    ],
    'vid-composting': [
      VideoComment(
        id: 'c6',
        videoId: 'vid-composting',
        author: 'Femi K.',
        avatarEmoji: '👨‍🌾',
        text: 'Six weeks is much faster than what I was doing before. Trying this now.',
        postedAt: DateTime.now().subtract(const Duration(hours: 20)),
      ),
      VideoComment(
        id: 'c7',
        videoId: 'vid-composting',
        author: 'Aisha M.',
        avatarEmoji: '👩‍🌾',
        text: 'Great breakdown of the three-bin rotation, very clear.',
        postedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ],
    'vid-nitrogen-deficiency': [
      VideoComment(
        id: 'c8',
        videoId: 'vid-nitrogen-deficiency',
        author: 'Chinedu P.',
        avatarEmoji: '👨‍🌾',
        text: 'This explains exactly what I was seeing on my maize. Applying urea today.',
        postedAt: DateTime.now().subtract(const Duration(days: 18)),
      ),
    ],
    'vid-drip-irrigation': [
      VideoComment(
        id: 'c9',
        videoId: 'vid-drip-irrigation',
        author: 'Grace Adeyemi',
        avatarEmoji: '👩‍🌾',
        text: 'Pinned — remember to flush the lateral lines before your first full run.',
        postedAt: DateTime.now().subtract(const Duration(days: 29)),
      ),
    ],
    'vid-grain-storage': [],
  };

  int _commentSeq = 10;

  @override
  Future<List<TutorialVideo>> fetchVideos() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List.unmodifiable(_videos);
  }

  @override
  Future<List<VideoComment>> fetchComments(String videoId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List.unmodifiable(_comments[videoId] ?? const []);
  }

  @override
  Future<int> setLiked(String videoId, bool liked) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final index = _videos.indexWhere((v) => v.id == videoId);
    if (index == -1) return 0;
    final current = _videos[index];
    final updated = current.copyWith(
      isLiked: liked,
      likeCount: current.likeCount + (liked == current.isLiked ? 0 : (liked ? 1 : -1)),
    );
    _videos[index] = updated;
    return updated.likeCount;
  }

  @override
  Future<VideoComment> postComment(String videoId, String text) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final comment = VideoComment(
      id: 'c${_commentSeq++}',
      videoId: videoId,
      author: 'You',
      avatarEmoji: '🙂',
      text: text,
      postedAt: DateTime.now(),
    );
    _comments.update(
      videoId,
      (existing) => [...existing, comment],
      ifAbsent: () => [comment],
    );
    return comment;
  }
}
