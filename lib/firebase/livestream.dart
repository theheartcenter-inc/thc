import 'package:thc/firebase/user.dart';

class LiveStreamModel {
  LiveStreamModel({
    required this.liveStreamId,
    required this.title,
    required this.startTime,
    required this.viewers,
    required this.channelId,
    required this.directorId,
    required this.directorName,
  });

  factory LiveStreamModel.fromSnapshot(/*DocumentSnapshot*/ dynamic snapshot) {
    return LiveStreamModel(
      liveStreamId: snapshot['liveStreamId'],
      title: snapshot['title'],
      startTime: snapshot['startTime'] /*as Timestamp*/ .toDate(),
      channelId: snapshot['channelId'],
      directorId: snapshot['directorId'],
      directorName: snapshot['directorName'],
      viewers: snapshot['viewers'],
    );
  }

  String liveStreamId;
  String title;
  DateTime startTime;
  int viewers;
  String channelId;
  String directorId;
  String directorName;

  Json get json => {
        'liveStreamId': liveStreamId,
        'title': title,
        'startTime': startTime,
        'channelId': channelId,
        'directorId': directorId,
        'directorName': directorName,
        'viewers': viewers,
      };
}
