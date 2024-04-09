class LivestreamSchedule {
  const LivestreamSchedule({
    required this.directorId,
    required this.start,
    required this.duration,
    required this.live,
    // required this.participants,
  });

  final String directorId;
  final DateTime start;
  final Duration duration;
  final bool live;
  // final List<String> participants;
}
