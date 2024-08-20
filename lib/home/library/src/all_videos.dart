import 'package:thc/firebase/firebase_bloc.dart';
import 'package:thc/home/library/src/video_card.dart';
import 'package:thc/the_good_stuff.dart';

typedef Videos = List<VideoCard>;
typedef VideoData = ({List<String> categories, Videos? videos});

class ThcVideos extends FirebaseBloc<Videos> {
  ThcVideos() : super(Firestore.streams.snapshots, onData: _onData, data: []);

  static void _onData(Videos current, SnapshotDoc doc) {
    if (doc.data() case final json?) {
      final newVideo = VideoCard.fromJson(json, FirestoreID(doc.id));
      final int index = current.indexWhere(doc.match);
      if (index == -1) {
        current.add(newVideo);
      } else {
        current[index] = newVideo;
      }
    } else {
      current.removeWhere(doc.match);
    }
  }

  @override
  ValueGetter<Videos> isolateCallback(Videos current, SnapshotDocs docs) {
    return () {
      for (final SnapshotDoc doc in docs) {
        _onData(current, doc);
      }
      return current;
    };
  }

  static VideoData of(BuildContext context, String category, String search) {
    Iterable<VideoCard> videos = context.watch<ThcVideos>().data;
    if (videos.isEmpty) return (categories: const [], videos: null);

    final categories = <String>[
      'All',
      'Pinned',
      ...{for (final video in videos) video.category}.toList()..sort(),
    ];
    assert(categories.contains(category), 'invalid category: $category');

    videos = switch (category) {
      'All' => videos,
      'Pinned' => videos.where((video) => UserPins.contains(context, video.firestoreId)),
      _ => videos.where((video) => video.category == category),
    };
    if (search.isNotEmpty) {
      videos = videos.where(
        (video) =>
            video.title.toLowerCase().contains(search) ||
            video.director.toLowerCase().contains(search),
      );
    }

    return (categories: categories, videos: videos.toList());
  }
}

typedef Pins = Set<String>;

class UserPins extends FirebaseBloc<Pins> {
  UserPins() : super(user.streamData.snapshots, onData: _onData, data: {});

  static void _onData(Pins current, SnapshotDoc doc) {
    if (doc.data()!['pinned'] as bool) {
      current.add(doc.id);
    } else {
      current.remove(doc.id);
    }
  }

  @override
  ValueGetter<Pins> isolateCallback(Pins current, SnapshotDocs docs) {
    return () {
      for (final doc in docs) {
        _onData(current, doc);
      }
      return current;
    };
  }

  static Pins of(BuildContext context) => context.watch<UserPins>().data;

  static bool contains(BuildContext context, String id) =>
      context.select<UserPins, bool>((pins) => pins.data.contains(id));
}
