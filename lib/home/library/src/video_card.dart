import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:thc/firebase/firebase_bloc.dart';
import 'package:thc/home/library/src/all_videos.dart';
import 'package:thc/home/library/src/play_video.dart';
import 'package:thc/the_good_stuff.dart';
import 'package:universal_html/html.dart' as html;

/// {@template VideoCard}
/// A class that holds the metadata for a video in the recorded library.
///
/// Can be built into a [Card] widget that plays (or downloads) the video when tapped.
/// {@endtemplate}
class VideoCard extends StatelessWidget {
  /// {@macro VideoCard}
  const VideoCard({
    required FirestoreID id,
    required this.title,
    required this.timestamp,
    required this.director,
    required this.category,
    required this.path,
    this.thumbnail,
  }) : super(key: id);

  VideoCard.fromJson(Json json, FirestoreID id)
      : this(
          id: id,
          title: json['title'] ?? '[title not found]',
          category: json['category'] ?? '[category not found]',
          director: json['director'] ?? '[director not found]',
          path: json['storage_path'] ?? '[path not found]',
          timestamp: json['date'] ?? Timestamp.now(),
          // thumbnail: json['thumbnail'],
        );

  final String title;
  final Timestamp timestamp;
  final String director;
  final String category;
  final String path;
  final String? thumbnail;

  Json get json => {
        'title': title,
        'date': timestamp,
        'director': director,
        'category': category,
        'storage_path': path,
        'thumbnail': thumbnail,
      };

  Future<void> upload() => Firestore.streams.doc(firestoreId).set(json);

  static const _margin = EdgeInsets.symmetric(vertical: 8.0);

  static const blank = Card(
    clipBehavior: Clip.antiAlias,
    margin: _margin,
    color: Colors.white,
    child: ListTile(
      title: ColoredBox(
        color: Color(0xffbbbbbb),
        child: SizedBox(width: 100, height: 20),
      ),
      subtitle: ColoredBox(
        color: Color(0xffeeeeee),
        child: SizedBox(width: 150, height: 20),
      ),
      leading: ColoredBox(
        color: Color(0xffbbbbbb),
        child: SizedBox(width: 100, height: 100),
      ),
    ),
  );

  Future<String> getDownloadURL() => FirebaseStorage.instance.ref().child(path).getDownloadURL();

  Future<void> play() async {
    Future<String?> openVideoPlayer() async {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
        return 'not supported on Windows';
      }

      String? url;
      try {
        url = await getDownloadURL();
      } catch (e) {
        return '${e.runtimeType} has occurred: $e';
      }
      navigator.push(PlayVideo(videoURL: url, videoName: title));
      return null;
    }

    if (await openVideoPlayer() case final errorMessage?) {
      navigator.snackbarMessage('$errorMessage :(');
    }
  }

  Future<void> download() async {
    try {
      final String url = await getDownloadURL();

      if (kIsWeb) {
        html.AnchorElement(href: url)
          ..setAttribute('downloadVideo', title)
          ..click();
      } else {
        final dio = Dio();
        final savePath = './download_video/$title.mp4';

        await dio.download(url, savePath, onReceiveProgress: (received, total) {});
        navigator.snackbarMessage('Download completed: $savePath');
      }
    } on DioException catch (e) {
      navigator.snackbarMessage('Failed to download video: ${e.message}');
    } catch (e) {
      navigator.snackbarMessage('An error occurred: $e');
    }
  }

  Future<void> delete() async {
    final shouldDelete = await navigator.showDialog(
      Dialog.confirm(
        titleText: 'Delete Video',
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Do you want to delete the following video?'),
            const SizedBox(height: 16),
            Text(
              'title: $title\n' 'director: $director\n' 'category: $category',
              style: const TextStyle(size: 13, weight: 600),
            ),
          ],
        ),
      ),
    );
    if (shouldDelete == null) return;

    final loading = navigator.context.read<Loading>();
    loading.value = true;
    try {
      final doc = Firestore.streams.doc(firestoreId);
      final docSnapshot = await doc.get();
      if (docSnapshot.exists) {
        final Json json = docSnapshot.data()!;
        final Reference ref = FirebaseStorage.instance.ref().child(json['storage_path']);
        await Future.wait([
          doc.delete(),
          ref.delete(),
        ]);
      }
      navigator.snackbarMessage('Video successfully deleted!');
    } catch (e) {
      navigator.snackbarMessage('Failed to delete video!');
    }
    loading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = ThcColors.of(context);
    final bool loading = Loading.of(context);
    final Image image;
    if (thumbnail == null) {
      image = Image.asset(
        'assets/thc_thumbnail.jpg',
        width: 100,
        height: 100,
      );
    } else {
      image = Image.network(thumbnail!);
    }
    final String date = DateFormat('yyyy-MM-dd hh:mm a').format(timestamp.toDate());

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: _margin,
      color: colors.surfaceContainerLowest.withOpacity(loading ? 2 / 3 : 1),
      shadowColor: loading ? Colors.transparent : null,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(weight: 650, color: Colors.black),
        ),
        subtitle: Text(
          '$director • $date',
          style: const TextStyle(color: Colors.black),
        ),
        onTap: loading ? null : play,
        hoverColor: ThcColors.dullBlue.withOpacity(1 / 16),
        leading: image,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (Editing.of(context))
              IconButton(
                style: IconButton.styleFrom(foregroundColor: colors.error),
                icon: const Icon(Icons.delete),
                onPressed: loading ? null : delete,
              )
            else ...[
              FavoriteIconButton(streamId: firestoreId),
              IconButton(icon: const Icon(Icons.download), onPressed: download),
            ]
          ],
        ),
      ),
    );
  }
}

class FavoriteIconButton extends StatelessWidget {
  const FavoriteIconButton({super.key, required this.streamId});

  final String streamId;

  static Future<void> toggleFavorite(String id) async {
    final DocumentReference<Json> doc = user.streamData.doc(id);
    final SnapshotDoc snapshot = await doc.get();
    if (snapshot.exists) {
      final bool pinned = snapshot['pinned'];
      return doc.update({'pinned': !pinned});
    } else {
      return doc.set({'pinned': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool pinned = UserPins.contains(context, streamId);
    return IconButton(
      icon: Icon(pinned ? Icons.star : Icons.star_border),
      color: pinned ? Colors.orange : Colors.grey,
      onPressed: () => toggleFavorite(streamId),
    );
  }
}
