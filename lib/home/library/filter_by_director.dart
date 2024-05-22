import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/library/play_video.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';
import 'package:thc/utils/local_storage.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({
    Key? key,
    required this.title,
    required this.timestamp,
    required this.director,
    required this.category,
    required this.id,
    required this.path,
    this.thumbnail,
  }) : super(key: key);

  final String title;
  final Timestamp timestamp;
  final String director;
  final String category;
  final String id;
  final String path;
  final String? thumbnail;

  Future<String?> playVideo() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      return 'not supported on Windows';
    }

    String? url;
    try {
      final storageReference = FirebaseStorage.instance.ref().child(path);
      url = await storageReference.getDownloadURL();
    } catch (e) {
      return '${e.runtimeType} has occurred: $e';
    }
    navigator.push(PlayVideo(videoURL: url, videoName: title));
    return null;
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
    final format = DateFormat('yyyy-MM-dd hh:mm a');
    final DateTime date = DateTime.parse(timestamp.toDate().toString());
    final formatedDate = format.format(date);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(10),
      color: Colors.white,
      child: ListTile(
        title: Text(
          title,
          style: const StyleText(weight: 650, color: Colors.black),
        ),
        subtitle: Text(
          '$director • $formatedDate',
          style: const StyleText(color: Colors.black),
        ),
        onTap: () async {
          if (await playVideo() case final errorMessage?) {
            navigator.showSnackBar(SnackBar(content: Text('$errorMessage :(')));
          }
        },
        hoverColor: ThcColors.dullBlue.withOpacity(1 / 8),
        leading: image,
      ),
    );
  }
}

class VideoLibrary extends StatefulWidget {
  const VideoLibrary({Key? key}) : super(key: key);

  @override
  State<VideoLibrary> createState() => _VideoLibraryState();
}

class _VideoLibraryState extends State<VideoLibrary> {
  final TextEditingController controller = TextEditingController();
  String selectedCategory = 'All';
  List<VideoCard> allVideos = [];
  List<VideoCard> videos = [];
  Set<String> ids = {};

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    final user = LocalStorage.getUser(); 
    final QuerySnapshot snapshot = await Firestore.streams.where('director', isEqualTo: user.id).get();
    setState(() {
      videos = allVideos = [
        for (final document in snapshot.docs)
          VideoCard(
            id: document.id,
            title: document['title'],
            category: document['category'],
            director: document['director'],
            path: document['storage_path'],
            timestamp: document['date'],
          ),
      ];
    });
  }

  List<String> get categories {
    final categories = {
      'All',
      for (final video in allVideos) video.category,
    };
    return categories.toList()..sort();
  }

  void searchVideo(String query) {
    filterVideos();
    setState(() {
      if (query.isNotEmpty) {
        videos = videos.where((video) {
          if (ids.contains(video.id)) return false;

          final videoTitle = video.title.toLowerCase();
          final input = query.toLowerCase();
          ids.add(video.id);
          return videoTitle.contains(input);
        }).toList();
      }
      ids = {};
    });
  }

  void filterVideos() {
    if (selectedCategory != 'All') {
      setState(() {
        videos = allVideos.where((video) => video.category == selectedCategory).toList();
      });
    } else {
      setState(() {
        videos = allVideos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (allVideos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search here',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: searchVideo,
          ),
        ),
        DropdownButton<String>(
          value: selectedCategory,
          onChanged: (newValue) {
            setState(() {
              selectedCategory = newValue!;
              filterVideos();
            });
          },
          items: [
            for (final category in categories)
              DropdownMenuItem<String>(value: category, child: Text(category)),
          ],
        ),
        Expanded(child: ListView(children: videos)),
      ],
    );
  }
}
