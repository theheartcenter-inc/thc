/// This file imports credentials from a git submodule to configure our Agora settings.
///
/// By using a private submodule, we can be a part of the
/// [open source initiative](https://opensource.org/) and still maintain security!
library;

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:thc/models/credentials/credentials.dart';

const engineContext = RtcEngineContext(
  appId: AgoraCredentials.id,
  channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
);
