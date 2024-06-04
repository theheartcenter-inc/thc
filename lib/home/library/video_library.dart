import 'package:flutter/material.dart';
import 'package:thc/home/library/src/all_videos.dart';
import 'package:thc/home/library/src/video_card.dart';
import 'package:thc/utils/bloc.dart';

class VideoLibrary extends HookWidget {
  const VideoLibrary({super.key});

  @override
  Widget build(BuildContext context) {
    final category = useState('All');
    final search = useState('');

    final (:videos, :categories) = ThcVideos.of(context, category.value, search.value);

    if (videos == null) return const Center(child: CircularProgressIndicator());

    const decoration = InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search');
    final dropdownButton = DropdownButton<String>(
      focusColor: Colors.transparent,
      value: category.value,
      onChanged: category.update,
      underline: const SizedBox.shrink(),
      padding: const EdgeInsets.only(left: 8, right: 4),
      items: [
        for (final String category in categories)
          DropdownMenuItem(value: category, child: Text(category)),
      ],
    );
    final searchBox = LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 600) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TextField(
            decoration: decoration.copyWith(suffixIcon: dropdownButton),
            onChanged: (text) => search.value = text.toLowerCase(),
          ),
        );
      }

      return Column(
        children: [
          TextField(
            decoration: decoration,
            onChanged: (text) => search.value = text.toLowerCase(),
          ),
          dropdownButton,
        ],
      );
    });

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          searchBox,
          Expanded(
            child: ListView.builder(
              itemCount: videos.length,
              itemBuilder: (context, index) => videos[index],
              prototypeItem: VideoCard.blank,
            ),
          ),
        ],
      ),
    );
  }
}
