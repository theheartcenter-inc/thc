import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thc/the_good_stuff.dart';
import '../agora_user.dart';
import 'package:thc/firebase/firebase.dart';
import 'call_actions_row.dart';

class BroadcastStream extends StatefulWidget {
  const BroadcastStream({
    super.key,
    required this.appId,
    required this.token,
    required this.channelName,
    required this.isMicEnabled,
    required this.isVideoEnabled,
    required this.director,
  });

  final String appId;
  final String token;
  final String channelName;
  final bool isMicEnabled;
  final bool isVideoEnabled;
  final bool director;

  @override
  State<BroadcastStream> createState() => _BroadcastStreamState();
}

class _BroadcastStreamState extends State<BroadcastStream> {
  int? _remoteUid; // The UID of the remote user
  bool _localUserJoined = false; // Indicates whether the local user has joined the channel
  late RtcEngine _engine; // The RtcEngine instances
  late final _users = <AgoraUser>{};
  late final _directors = <AgoraUser>{};
  late double _viewAspectRatio;

  int? _currentUid;
  bool _isMicEnabled = false;
  bool _isVideoEnabled = false;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // await [Permission.microphone, Permission.camera].request();
    // Set aspect ratio for video according to platform
    if (kIsWeb) {
      _viewAspectRatio = 3 / 2;
    } else if (Platform.isAndroid || Platform.isIOS) {
      _viewAspectRatio = 2 / 3;
    } else {
      _viewAspectRatio = 3 / 2;
    }

    setState(() {
      _isMicEnabled = widget.isMicEnabled;
      _isVideoEnabled = widget.isVideoEnabled;
    });

    // Create RtcEngine instance
    _engine = createAgoraRtcEngine();
    // Initialize RtcEngine and set the channel profile to live broadcasting
    await _engine.initialize(RtcEngineContext(
      appId: widget.appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    // Add an event handler
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        // Occurs when the local user joins the channel successfully
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint('local user ${connection.localUid} joined');
          setState(() {
            _localUserJoined = true;
            _currentUid = connection.localUid;
            _users.add(
              AgoraUser(
                uid: connection.localUid!,
                isAudioEnabled: _isMicEnabled,
                isVideoEnabled: _isVideoEnabled,
              ),
            );
            if (widget.director) {
              _directors.add(
                AgoraUser(
                  uid: connection.localUid!,
                  isAudioEnabled: _isMicEnabled,
                  isVideoEnabled: _isVideoEnabled,
                  director: true,
                ),
              );
            }
          });
        },
        // Occurs when a remote user join the channel
        onUserJoined: (connection, remoteUid, elapsed) {
          debugPrint('remote user $remoteUid joined');
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        // Occurs when a remote user leaves the channel
        onUserOffline: (connection, remoteUid, reason) {
          debugPrint('remote user $remoteUid left channel');
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );
    // Enable the video module
    await _engine.enableVideo();
    // Enable local video preview
    await _engine.startPreview();
  }

  Future<void> _onCallEnd(BuildContext context) async {
    // Todo: Add call for endstream questions and based on if end early or end on time
    await _engine.leaveChannel();
    if (context.mounted) {
      navigator.pop(true);
    }
  }

  void _onToggleAudio() {
    setState(() {
      _isMicEnabled = !_isMicEnabled;
      if (_isMicEnabled) {
        _engine.enableAudio();
      } else {
        _engine.disableAudio();
      }
      for (AgoraUser user in _directors) {
        if (user.uid == _currentUid) {
          user.isAudioEnabled = _isMicEnabled;
        }
      }
    });
    _engine.muteLocalAudioStream(!_isMicEnabled);
  }

  void _onToggleCamera() {
    setState(() {
      _isVideoEnabled = !_isVideoEnabled;
      if (_isVideoEnabled) {
        _engine.enableVideo();
      } else {
        _engine.disableVideo();
      }
      for (AgoraUser director in _directors) {
        if (director.uid == _currentUid) {
          setState(() => director.isVideoEnabled = _isVideoEnabled);
        }
      }
    });
    _engine.muteLocalVideoStream(!_isVideoEnabled);
  }

  void _onSwitchCamera() => _engine.switchCamera();

  List<int> _createLayout(int n) {
    final int rows = sqrt(n).ceil();
    final int columns = (n / rows).ceil();

    final List<int> layout = List<int>.filled(rows, columns);
    final int remainingScreens = rows * columns - n;

    for (int i = 0; i < remainingScreens; i++) {
      layout[layout.length - 1 - i] -= 1;
    }

    return layout;
  }

  @override
  void dispose() {
    _users.clear();
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    // Leave the channel
    await _engine.leaveChannel();
    // Release resources
    await _engine.release();
  }

  // Build the UI to display local and remote videos
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.black,
        centerTitle: false,
        title: Row(
          children: [
            const Icon(
              Icons.meeting_room_rounded,
              color: Colors.white54,
            ),
            const SizedBox(width: 6.0),
            const Text(
              'Channel name: ',
              style: TextStyle(
                color: Colors.white54,
                weight: 16.0,
              ),
            ),
            Text(
              widget.channelName,
              style: const TextStyle(
                color: Colors.white,
                size: 16.0,
                weight: 20,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.people_alt_rounded,
                  color: Colors.white54,
                ),
                const SizedBox(width: 6.0),
                Text(
                  _users.length.toString(),
                  style: const TextStyle(
                    color: Colors.white54,
                    size: 16.0,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    final isPortrait = orientation == Orientation.portrait;
                    if (_directors.isEmpty) {
                      return const SizedBox();
                    }
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => setState(() => _viewAspectRatio = isPortrait ? 2 / 3 : 3 / 2),
                    );
                    final layoutViews = _createLayout(_users.length);
                    return AgoraVideoLayout(
                      directors: _directors,
                      views: layoutViews,
                      viewAspectRatio: _viewAspectRatio,
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Builder(
                builder: (context) {
                  if (widget.director) {
                    return CallActionsRow(
                      isMicEnabled: _isMicEnabled,
                      isVideoEnabled: _isVideoEnabled,
                      onCallEnd: () => _onCallEnd(context),
                      onToggleAudio: _onToggleAudio,
                      onToggleCamera: _onToggleCamera,
                      onSwitchCamera: _onSwitchCamera,
                    );
                  }
                  return CallActionsRow(
                    isMicEnabled: false,
                    isVideoEnabled: false,
                    onCallEnd: () => _onCallEnd(context),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AgoraVideoLayout extends StatelessWidget {
  const AgoraVideoLayout({
    super.key,
    required Set<AgoraUser> directors,
    required List<int> views,
    required double viewAspectRatio,
  })  : _directors = directors,
        _views = views,
        _viewAspectRatio = viewAspectRatio;

  final Set<AgoraUser> _directors;
  final List<int> _views;
  final double _viewAspectRatio;

  @override
  Widget build(BuildContext context) {
    final int totalCount = _views.reduce((value, element) => value + element);
    final int rows = _views.length;
    final int columns = _views.reduce(max);

    final List<Widget> rowsList = [];
    for (int i = 0; i < rows; i++) {
      final List<Widget> rowChildren = [];
      for (int j = 0; j < columns; j++) {
        final int index = i * columns + j;
        if (index < totalCount) {
          rowChildren.add(
            AgoraVideoView(
              user: _directors.elementAt(index),
              viewAspectRatio: _viewAspectRatio,
            ),
          );
        } else {
          rowChildren.add(
            const SizedBox.shrink(),
          );
        }
      }
      rowsList.add(
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: rowChildren,
          ),
        ),
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: rowsList,
    );
  }
}

class AgoraVideoView extends StatelessWidget {
  const AgoraVideoView({
    super.key,
    required double viewAspectRatio,
    required AgoraUser user,
  })  : _viewAspectRatio = viewAspectRatio,
        _user = user;

  final double _viewAspectRatio;
  final AgoraUser _user;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: AspectRatio(
          aspectRatio: _viewAspectRatio,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: _user.isAudioEnabled ?? false ? Colors.blue : Colors.red,
                width: 2.0,
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: CircleAvatar(
                    backgroundColor: Colors.grey.shade800,
                    maxRadius: 18,
                    child: Icon(
                      Icons.person,
                      color: Colors.grey.shade600,
                      size: 24.0,
                    ),
                  ),
                ),
                if (_user.isVideoEnabled ?? false)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8 - 2),
                    child: _user.view,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
