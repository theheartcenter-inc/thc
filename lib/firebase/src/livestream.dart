import 'package:thc/firebase/firebase.dart';

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

  factory LiveStreamModel.fromJson(Json json) {
    return LiveStreamModel(
      liveStreamId: json['liveStreamId'],
      title: json['title'],
      startTime: json['startTime'], // as Timestamp.toDate(),
      channelId: json['channelId'],
      directorId: json['directorId'],
      directorName: json['directorName'],
      viewers: json['viewers'],
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
