/// This file imports credentials from a git submodule to configure our Agora settings.
///
/// By using a private submodule, we can join the [open source initiative](https://opensource.org/)
/// and still maintain security!
library;

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thc/models/credentials/credentials.dart';

abstract final class Agora {
  static late final RtcEngine _engine;
  static double viewerCount = 0;

  static Future<void> init() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: AgoraCredentials.id,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));
  }

  static Future<void> watchLivestream() async {
    await _engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.joinChannel(
      token: AgoraCredentials.token,
      channelId: AgoraCredentials.channel,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  static Future<void> createLivestream() async {
    await [Permission.microphone, Permission.camera].request();

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.joinChannel(
      token: AgoraCredentials.token,
      channelId: AgoraCredentials.channel,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }
}
