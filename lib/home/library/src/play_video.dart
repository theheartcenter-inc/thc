import 'package:flutter/material.dart';
import 'package:thc/home/library/src/video_controller_hook.dart';
import 'package:thc/utils/bloc.dart';

class PlayVideo extends HookWidget {
  const PlayVideo({super.key, required this.videoURL, required this.videoName});

  final String videoURL;
  final String videoName;

  @override
  Widget build(BuildContext context) {
    final VideoController controller = useCustomVideoPlayerController(url: videoURL);

    return Scaffold(
      appBar: AppBar(title: Text(videoName)),
      body: Center(
        child: CustomVideoPlayer(customVideoPlayerController: controller),
      ),
    );
  }
}
