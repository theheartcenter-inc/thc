import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/firebase/firebase_bloc.dart';
import 'package:thc/home/library/src/all_videos.dart';
import 'package:thc/home/library/src/play_video.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/theme.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:universal_html/html.dart' as html;

/// {@template VideoCard}
/// A class that holds the metadata for a video in the recorded library.
///
/// Can be built into a [Card] widget that plays (or downloads) the video when tapped.
/// {@endtemplate}
class VideoCard extends StatelessWidget {
  /// {@macro VideoCard}
  const VideoCard({
    required Key super.key,
    required this.title,
    required this.timestamp,
    required this.director,
    required this.category,
    required this.path,
    this.thumbnail,
  });

  VideoCard.fromJson(Json json, {required Key super.key})
      : title = json['title'],
        category = json['category'],
        director = json['director'],
        path = json['storage_path'],
        timestamp = json['date'],
        thumbnail = null; // = json['thumbnail'];

  final String title;
  final Timestamp timestamp;
  final String director;
  final String category;
  final String path;
  final String? thumbnail;

  static const margin = EdgeInsets.symmetric(vertical: 8.0);

  static const blank = Card(
    clipBehavior: Clip.antiAlias,
    margin: margin,
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

  Future<String?> playVideo() async {
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

  Future<void> downloadVideo() async {
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

  @override
  Widget build(BuildContext context) {
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
      margin: margin,
      color: Colors.white,
      child: ListTile(
        title: Text(
          title,
          style: const StyleText(weight: 650, color: Colors.black),
        ),
        subtitle: Text(
          '$director • $date',
          style: const StyleText(color: Colors.black),
        ),
        onTap: () async {
          if (await playVideo() case final errorMessage?) {
            navigator.snackbarMessage('$errorMessage :(');
          }
        },
        hoverColor: ThcColors.dullBlue.withOpacity(1 / 8),
        leading: image,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FavoriteIconButton(streamId: keyVal),
            IconButton(icon: const Icon(Icons.download), onPressed: downloadVideo),
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
