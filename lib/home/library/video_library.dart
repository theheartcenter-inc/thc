import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
      this.category,
      this.id,
      this.path});
  final String title;
  final Timestamp timestamp;
  final String? thumbnail;
  final String director;
  final String? path;
  final category;
  final id;

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

  Future<String> getDownloadUrl(path) async {
    final Reference storageReference = FirebaseStorage.instance.ref().child(path);
    final String downloadURL = await storageReference.getDownloadURL();
    return downloadURL;
  }
}

class VideoLibrary extends StatefulWidget {
  const VideoLibrary({super.key});

  @override
  State<VideoLibrary> createState() => _VideoLibraryState();
}

class _VideoLibraryState extends State<VideoLibrary> {
  final TextEditingController controller = TextEditingController();
  String selectedCategory = 'All';
  List<VideoCard> allVideos = [];
  List<VideoCard> videos = [];
  // final CollectionReference collectionRef = FirebaseFirestore.instance.collection('streams');
  List<DocumentSnapshot> documents = [];
  var document;
  Set ids = {};

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  Future<void> fetchDocuments() async {
    final QuerySnapshot snapshot = await Firestore.streams.get();
    setState(() {
      documents = snapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      fetchDocuments();
      return const CircularProgressIndicator();
    } else {
      if (allVideos.isEmpty) {
        for (document in documents) {
          allVideos.add(VideoCard(
            id: document.id,
            title: document['title'],
            category: document['category'],
            director: document['director'],
            path: document['storage_path'],
            timestamp: document['date'],
          ));
        }

        videos = allVideos;
      }

      return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Video Library'),
            ),
            body: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                  items: _buildCategoryDropdownItems(),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        final video = videos[index];
                        return video;
                      }),
                ),
              ],
            ),
          ));
    }
  }

  List<DropdownMenuItem<String>> _buildCategoryDropdownItems() {
    final categories = {
      'All',
      for (final video in allVideos) video.category,
    };
    final items = [
      for (final category in categories.toList()..sort())
        DropdownMenuItem<String>(value: category, child: Text(category)),
    ];
    return items;
  }

  void searchVideo(String query) {
    filterVideos();
    setState(
      () {
        if (query.isNotEmpty) {
          videos = videos.where((video) {
            if (!ids.contains(video.id)) {
              final videoTitle = video.title.toLowerCase();
              final input = query.toLowerCase();
              ids.add(video.id);
              return videoTitle.contains(input);
            } else {
              return false;
            }
          }).toList();
        }
        ids = {};
      },
    );
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
}
