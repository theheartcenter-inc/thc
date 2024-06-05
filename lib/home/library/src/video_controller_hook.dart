import 'package:appinio_video_player/appinio_video_player.dart';
import 'package:thc/the_good_stuff.dart';

export 'package:appinio_video_player/appinio_video_player.dart' show CustomVideoPlayer;

typedef VideoController = CustomVideoPlayerController;

VideoController useCustomVideoPlayerController({required String url}) =>
    use(_VideoControllerHook(url: url));

class _VideoControllerHook extends Hook<VideoController> {
  const _VideoControllerHook({required this.url});
  final String url;

  @override
  _VideoControllerHookState createState() => _VideoControllerHookState();
}

class _VideoControllerHookState extends HookState<VideoController, _VideoControllerHook> {
  late final VideoController _videoController;

  @override
  void initHook() {
    final videoPlayerController = CachedVideoPlayerController.network(hook.url)
      ..initialize().then((_) => context.mounted ? setState(() {}) : null);

    _videoController = VideoController(
      context: context,
      videoPlayerController: videoPlayerController,
    );
  }

  @override
  void dispose() => _videoController.dispose();

  @override
  VideoController build(BuildContext context) => _videoController;
}
