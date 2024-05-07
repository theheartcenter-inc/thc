import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/library/play_video.dart';
import 'package:thc/utils/theme.dart';
import 'package:intl/intl.dart';

class VideoCard extends StatelessWidget {
  const VideoCard(
      {super.key,
      required this.title,
      required this.timestamp,
      this.thumbnail,
      required this.director,
      this.path});
  final String title;
  final Timestamp timestamp;
  final String? thumbnail;
  final String director;
  final String? path;

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
      //Will likely change how we get thumbnails in the future
      image = Image.network(thumbnail!);
    }
    final format = DateFormat('yyyy-dd-MM hh:mm a');
    final DateTime date = DateTime.parse(timestamp.toDate().toString());
    final formatedDate = format.format(date);

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.all(8.0),
        color: Colors.white,
        child: ListTile(
          title: Text(
            title,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          subtitle: Text(
            '$director • $formatedDate',
            style:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black),
          ),
          //Add screen to play selected video
          onTap: () async {
            final url = await getDownloadUrl(path);

            Navigator.of(context).push(MaterialPageRoute(builder: (_) {
              // return const PlayVideo();
              try {
                return PlayVideo(
                  videoURL: url,
                  videoName: title,
                );
              } catch (e) {
                return const Text('There was an error please try again later');
              }

              // return const Text('play video');
            }));
          },
          hoverColor: ThcColors.dullBlue.withOpacity(1 / 8),
          leading: image,
        ),
      ),
    );
  }
}

class VideoLibrary extends StatefulWidget {
  const VideoLibrary({super.key});

  @override
  State<VideoLibrary> createState() => _VideoLibraryState();
}

class _VideoLibraryState extends State<VideoLibrary> {
  @override
  Widget build(BuildContext context) {
    final videoCards = StreamBuilder<QuerySnapshot>(
      stream: Firestore.streams.snapshots(),
      builder: (context, snapshot) => Column(
        children: [
          if (snapshot.data?.docs.reversed case final streams?)
            for (final stream in streams)
              if ('${stream['storage_path']}' != '')
                VideoCard(
                  title: stream['title'],
                  timestamp: stream['date'],
                  director: stream['director'],
                  path: stream['storage_path'],
                )
        ],
      ),
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Video Library',
            ),
            bottom: const TabBar(
              tabs: [
                Tab(
                  text: 'Recent',
                ),
                Tab(
                  text: 'Favorites',
                )
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              SingleChildScrollView(
                child: videoCards,
              ),
              SingleChildScrollView(
                // Replace with user's favorite videos
                child: VideoCard(
                  director: 'FirstName LastName',
                  title: 'Test Favorite Video',
                  timestamp: Timestamp.now(),
                ),
              ),
            ],
          )),
    );
  }
}

Future<String> getDownloadUrl(path) async {
  final Reference storageReference = FirebaseStorage.instance.ref().child(path);
  final String downloadURL = await storageReference.getDownloadURL();
  return downloadURL;
}
