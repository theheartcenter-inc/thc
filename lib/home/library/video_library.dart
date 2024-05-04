import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/utils/theme.dart';
import 'package:intl/intl.dart';

// class VideoBlocks extends StatelessWidget {
//   final Iterable<QueryDocumentSnapshot<Object?>>? videos;

//   VideoBlocks({required this.videos});

//   @override
//   Widget build(BuildContext context) {
//     for (video in videos) {}
//     return Container(
//         // Iterate through videos and create a list of video blocks with thumbnail, title and if date is after todays date.
//         );
//   }
// }
class VideoCard extends StatelessWidget {
  VideoCard(
      {super.key,
      required this.title,
      required this.timestamp,
      this.thumbnail,
      required this.director,
      this.path});
  final String title;
  final Timestamp timestamp;
  String? thumbnail;
  String director;
  String? path;

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
      image = Image.asset('assets/profile_placeholder.jpg');
      //Image.network(url)
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
          onTap: () {},
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
    final videoBlocks = StreamBuilder<QuerySnapshot>(
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Video Library',
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: videoBlocks,
        ),
      ),
    );
  }
}