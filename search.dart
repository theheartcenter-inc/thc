import 'package:flutter/material.dart';
// i am not sure what this functionality filters/ searches for?? videos? users? livestream?
class Video {
  final String title;
  final String url;
  final String category;

  const Video({
    required this.title,
    required this.url,
    required this.category,
  });
}
//I am unsure about what needs to happen here: Import the data maybe?
const List<Video> allVideos = [
  Video(
    title: 'Breathing exercise ',
    url: 'https://thc.com/breathing.mp4',
    category: 'Breathing',
  ),
  Video(
    title: 'Video 2',
    url: 'https:..mp4',
    category: 'Meditation',
  ),
  // Do we have a databases for video's /how will this work?
];

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController controller = TextEditingController();
  String selectedCategory = 'All';
  List<Video> videos = allVideos;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search and Filter Videos'),
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
                  borderSide: const BorderSide(),
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
                return ListTile(
                  leading: Image.network(
                    video.url,
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                  ),
                  title: Text(video.title),
                  subtitle: Text(video.category),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VideoPage(video: video)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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
    setState(() {
      videos = allVideos.where((video) {
        final videoTitle = video.title.toLowerCase();
        final input = query.toLowerCase();
        return videoTitle.contains(input);
      }).toList();
      filterVideos();
    });
  }

  void filterVideos() {
    if (selectedCategory != 'All') {
      setState(() {
        videos = videos.where((video) => video.category == selectedCategory).toList();
      });
    }
  }
}

class VideoPage extends StatelessWidget {
  final Video video;

  const VideoPage({Key? key, required this.video}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(video.title),
      ),
      body: Center(
        child: Text('Watch Video here'),
      ),
    );
  }
}