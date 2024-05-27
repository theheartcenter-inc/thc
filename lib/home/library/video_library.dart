import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thc/firebase/firebase.dart';
import 'package:thc/home/library/play_video.dart';
import 'package:thc/utils/navigator.dart';
import 'package:thc/utils/style_text.dart';
import 'package:thc/utils/theme.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:universal_html/html.dart' as html;

class FavoriteIconButton extends StatefulWidget {
  const FavoriteIconButton({
    super.key,
    required this.isPinned,
    required this.onFavoriteToggle,
  });
  final bool isPinned;
  final VoidCallback onFavoriteToggle;

  @override
  _FavoriteIconButtonState createState() => _FavoriteIconButtonState();
}

class _FavoriteIconButtonState extends State<FavoriteIconButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(widget.isPinned ? Icons.star : Icons.star_border),
      color: widget.isPinned ? Colors.orange : Colors.grey,
      onPressed: widget.onFavoriteToggle,
    );
  }
}

class VideoCard extends StatelessWidget {
  const VideoCard({
    super.key,
    required this.title,
    required this.timestamp,
    required this.director,
    required this.category,
    required this.id,
    required this.path,
    this.thumbnail,
    this.isPinned = false,
    required this.onFavoriteToggle,
  });

  final String title;
  final Timestamp timestamp;
  final String director;
  final String category;
  final String id;
  final String path;
  final String? thumbnail;
  final bool isPinned;
  final VoidCallback onFavoriteToggle;

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

  // Add a method to toggle the pinned status
  Future<void> togglePinnedStatus() async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc('test_participant');
    final streamDoc = userDoc.collection('streams').doc(id);

    // Get the current pinned status
    final docSnapshot = await streamDoc.get();
    if (docSnapshot.exists) {
      final currentPinnedStatus = docSnapshot.data()?['pinned'] ?? false;
      // Update the pinned status to the opposite value
      await streamDoc.update({'pinned': !currentPinnedStatus});
    }
  }

  // Add a method to download the video
  Future<void> downloadVideo(BuildContext context) async {
    try {
      // Retrieve the download URL from Firebase Storage
      final storageReference = FirebaseStorage.instance.ref().child(path);
      final url = await storageReference.getDownloadURL();

      if (kIsWeb) {
        // Handle download for web environment
        final html.AnchorElement anchorElement = html.AnchorElement(href: url)
          ..setAttribute('downloadVideo', title)
          ..click();
      } else {
        // Handle download for non-web environment
        final dio = Dio();
        final savePath = './download_video/$title.mp4';

        await dio.download(url, savePath, onReceiveProgress: (received, total) {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download completed: $savePath')),
        );
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download video: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
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
      // Will likely change how we get thumbnails in the future
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
        // Add a trailing favorite icon button
        // Add a download button
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Existing favorite icon button
            FavoriteIconButton(
              isPinned: isPinned,
              onFavoriteToggle: onFavoriteToggle,
            ),
            // New download icon button
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                await downloadVideo(context);
                // Show a confirmation message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download started!')),
                );
              },
            ),
          ],
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
    final QuerySnapshot snapshot = await Firestore.streams.get();
    final userSnapshot =
        await Firestore.users.doc('test_participant').collection('streams').get();
    final pinnedIds = userSnapshot.docs
        .where((doc) => doc.data()['pinned'] as bool)
        .map((doc) => doc.id)
        .toSet();
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
            isPinned: pinnedIds.contains(document.id),
            onFavoriteToggle: () => toggleFavorite(document.id),
          ),
      ];
    });
  }

  void toggleFavorite(String videoId) async {
    final docRef = Firestore.users.doc('test_participant').collection('streams').doc(videoId);
    final docSnapshot = await docRef.get();
    final isCurrentlyPinned = docSnapshot.data()?['pinned'] as bool? ?? false;

    await docRef.update({'pinned': !isCurrentlyPinned});
    fetchDocuments(); // Refresh the list after updating
  }

  List<String> get categories {
    final categories = {
      'All',
      'Pinned',
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
    if (selectedCategory == 'Pinned') {
      setState(() {
        videos = allVideos.where((video) => video.isPinned).toList();
      });
    } else if (selectedCategory != 'All') {
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
