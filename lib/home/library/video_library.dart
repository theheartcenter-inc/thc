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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thc/utils/widgets/error_dialog.dart';
import 'package:file_picker/file_picker.dart';

class FavoriteIconButton extends StatelessWidget {
  const FavoriteIconButton({
    super.key,
    required this.isPinned,
    required this.onFavoriteToggle,
  });
  final bool isPinned;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isPinned ? Icons.star : Icons.star_border),
      color: isPinned ? Colors.orange : Colors.grey,
      onPressed: onFavoriteToggle,
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
    required this.isAdmin,
    required this.onDelete,
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
  final bool isAdmin;
  final VoidCallback onDelete;

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
  Future<void> downloadVideo() async {
    try {
      // Retrieve the download URL from Firebase Storage
      final storageReference = FirebaseStorage.instance.ref().child(path);
      final url = await storageReference.getDownloadURL();

      if (kIsWeb) {
        // Handle download for web environment
        html.AnchorElement(href: url)
          ..setAttribute('downloadVideo', title)
          ..click();
      } else {
        // Handle download for non-web environment
        final dio = Dio();
        final savePath = './download_video/$title.mp4';

        await dio.download(url, savePath, onReceiveProgress: (received, total) {});
        navigator.showSnackBar(
          SnackBar(content: Text('Download completed: $savePath')),
        );
      }
    } on DioException catch (e) {
      navigator.showSnackBar(
        SnackBar(content: Text('Failed to download video: ${e.message}')),
      );
    } catch (e) {
      navigator.showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void confirmDelete(BuildContext context, String videoId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this video?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                deleteVideo(context, videoId); // Proceed with deleting the video
              },
            ),
          ],
        );
      },
    );
  }

  // Add a method to delete the video
  Future<void> deleteVideo(BuildContext context, String videoId) async {
    try {
      final doc = FirebaseFirestore.instance.collection('streams').doc(videoId);
      final docSnapshot = await doc.get();
      if (docSnapshot.exists) {
        final filePath = docSnapshot.data()?['storage_path'];
        final ref = FirebaseStorage.instance.ref().child(filePath);
        await ref.delete();
        await doc.delete();
        onDelete();
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Video successfully deleted!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to delete video!')));
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
              onPressed: downloadVideo,
            ),
            if (isAdmin)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => confirmDelete(context, id),
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
  String? userEmail;
  bool isAdmin = false; // This should be fetched based on the logged-in user's role

  @override
  void initState() {
    super.initState();
    getCurrentUserEmail();
    fetchDocuments();
  }

  void getCurrentUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userEmail = user.email; // Get the user's email
      checkAdminRole(); // Check if the user is an admin
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const ErrorDialog('Login Required!');
        },
      );
    }
  }

  // Fetching isAdmin status from Firestore
  void checkAdminRole() async {
    if (userEmail == null) return; // Ensure the userId is not null
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userEmail).get();
    setState(() {
      isAdmin = userDoc.data()?['type'] == 'Admin';
    });
  }

  Future<void> fetchDocuments() async {
    final QuerySnapshot snapshot = await Firestore.streams.get();
    final userStreamData = await user.streamData.get();
    final pinnedIds = {
      for (final doc in userStreamData.docs)
        if (doc.data()['pinned']) doc.id,
    };
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
            isAdmin: isAdmin,
            onDelete: () => onDelete(document.id),
          ),
      ];
    });
  }

  void onDelete(String videoId) {
    setState(() {
      // Remove the deleted video from the local list of videos
      allVideos.removeWhere((video) => video.id == videoId);
      videos.removeWhere((video) => video.id == videoId);
    });
    fetchDocuments();
  }

  void toggleFavorite(String videoId) async {
    final docRef = user.streamData.doc(videoId);
    final data = await docRef.getData();
    final bool isCurrentlyPinned = data?['pinned'] ?? false;

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
    setState(() {
      videos = switch (selectedCategory) {
        'All' => allVideos,
        'Pinned' => videos = allVideos.where((video) => video.isPinned).toList(),
        _ => allVideos.where((video) => video.category == selectedCategory).toList(),
      };
    });
  }

  Future selectFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    final Uint8List? fileBytes = result.files.first.bytes;
    final String fileName = result.files.first.name;
    try {
      final ref = FirebaseStorage.instance.ref(fileName);
      final uploadTask = ref.putData(fileBytes!);
      await uploadTask.whenComplete(() {
        if (uploadTask.snapshot.state == TaskState.success) {
          Navigator.of(context).pop();
          uploadDetailsDialog(context, fileName);
        } else {
          showDialog(
            context: context,
            builder: (context) {
              return const ErrorDialog('File upload failed.');
            },
          );
        }
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return const ErrorDialog('Error uploading file.');
        },
      );
    }
  }

  Future<void> uploadDetailsDialog(BuildContext context, String path) async {
    String category = '';
    String director = '';
    String title = '';
    final Timestamp date = Timestamp.now();
    path = 'gs://the-heart-center-app.appspot.com/$path';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Upload Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'Category'),
                onChanged: (value) {
                  category = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Director'),
                onChanged: (value) {
                  director = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) {
                  title = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                fetchDocuments();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newStreams = FirebaseFirestore.instance.collection('streams').doc();
                newStreams.set(
                  {
                    'category': category,
                    'date': date,
                    'director': director,
                    'id': newStreams.id,
                    'title': title,
                    'storage_path': path,
                  },
                );
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  allVideos.add(
                    VideoCard(
                      id: newStreams.id,
                      title: title,
                      category: category,
                      director: director,
                      path: path,
                      timestamp: date,
                      onFavoriteToggle: () => toggleFavorite(newStreams.id),
                      isAdmin: isAdmin,
                      onDelete: () => onDelete(newStreams.id),
                    ),
                  );
                  videos = allVideos;
                });
              },
              child: const Text('Upload'),
            ),
          ],
        );
      },
    );
  }

  void selectUploadFileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Upload your file'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              onPressed: selectFile,
              child: const Text('Upload File'),
            ),
          ],
        );
      },
    );
  }

  Future<void> handleFileUpload() async {
    selectUploadFileDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    if (allVideos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    const Widget blankCard = Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.all(10),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Library'),
      ),
      body: Column(
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
          Expanded(
            child: ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) => videos[index],
              prototypeItem: blankCard,
            ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: Colors.green,
              onPressed: handleFileUpload,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
