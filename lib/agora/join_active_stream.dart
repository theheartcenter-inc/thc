import 'package:flutter/material.dart';
import 'package:thc/agora/active_stream.dart';
import 'package:thc/agora/broadcasting/broadcast_stream.dart';
import 'package:thc/credentials/credentials.dart';
import 'package:thc/home/schedule/src/all_scheduled_streams.dart';
import 'package:thc/start/src/login_fields.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:thc/home/schedule/scheduled_stream_card.dart';
import 'package:thc/home/schedule/src/all_scheduled_streams.dart';

class JoinActiveStream extends StatefulWidget {
  const JoinActiveStream({super.key});

  @override
  State<JoinActiveStream> createState() => _JoinActiveStreamState();
}

class _JoinActiveStreamState extends State<JoinActiveStream> {
  late final FocusNode _unfocusNode;
  String? channelName;

  bool _isCreatingChannel = false;

  @override
  void initState() {
    super.initState();
    _unfocusNode = FocusNode();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  void _showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  getActiveStreams() {
    final (:active, :scheduled) = ScheduledStreams.of(context);
    var stream;
    final List<Widget> activeStreams = [];
    for (stream in active) {
      final activeStream = stream;
      activeStreams.add(
        Padding(
          padding: const EdgeInsets.all(1),
          child: Container(
              child: TextButton(
            onPressed: () => setState(() {
              channelName = activeStream.title;
              debugPrint(channelName);
            }),
            child: activeStream,
          )),
        ),
      );
    }
    return activeStreams;
  }

  Future<void> _joinCall(channelName, token) async {
    const appId = AgoraCredentials.appId;
    if (context.mounted) {
      Navigator.of(context).pop();
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BroadcastStream(
            appId: appId,
            token: token,
            channelName: channelName,
            isMicEnabled: false,
            isVideoEnabled: false,
            director: false,
          ),
        ),
      );
    }
  }

  Future<void> joinRoom() async {
    FocusScope.of(context).requestFocus(_unfocusNode);
    var channel = _isCreatingChannel;
    setState(() => channel = true);
    _isCreatingChannel = channel;
    final input = <String, dynamic>{
      'channelName': channelName,
      'expiryTime': 3600, // 1 hour
    };
    try {
      final response =
          await FirebaseFunctions.instance.httpsCallable('generateToken').call(input);
      final token = response.data as String?;
      if (token != null) {
        if (context.mounted) {
          _showSnackBar(
            context,
            'Token generated successfully!',
          );
        }
        await Future.delayed(
          const Duration(seconds: 1),
        );
        _joinCall(channelName, token);
      }
    } catch (e) {
      debugPrint(e as String?);
      _showSnackBar(
        context,
        'Error generating token: $e',
      );
    } finally {
      setState(() => _isCreatingChannel = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(_unfocusNode),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: const BackButton(),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenSize.width,
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsetsDirectional.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          0.0,
                          30.0,
                          0.0,
                          8.0,
                        ),
                        child: Text(
                          'Select Stream',
                          style: TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(bottom: 24.0),
                        child: Column(
                          children: getActiveStreams(),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      if (_isCreatingChannel)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [CircularProgressIndicator()],
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                            ),
                            onPressed: joinRoom,
                            child: const Text('Join Room'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
