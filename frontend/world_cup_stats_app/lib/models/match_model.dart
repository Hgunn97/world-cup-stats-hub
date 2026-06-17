class Match {
  final int id;
  final int matchNumber;
  final String stage;
  final String? groupCode;
  final int? homeTeamId;
  final String? homeTeamName;
  final String? homeTeamCountryCode;
  final int? awayTeamId;
  final String? awayTeamName;
  final String? awayTeamCountryCode;
  final int? homeScore;
  final int? awayScore;
  final String status;
  final DateTime kickOffUtc;
  final String? venue;
  final int? winnerTeamId;
  final String? winnerTeamName;
  final String? homeSourceDescription;
  final String? awaySourceDescription;

  Match(
      {required this.id,
      required this.matchNumber,
      required this.stage,
      this.groupCode,
      this.homeTeamId,
      this.homeTeamName,
      this.homeTeamCountryCode,
      this.awayTeamId,
      this.awayTeamName,
      this.awayTeamCountryCode,
      this.homeScore,
      this.awayScore,
      required this.status,
      required this.kickOffUtc,
      this.venue,
      this.winnerTeamId,
      this.winnerTeamName,
      this.homeSourceDescription,
      this.awaySourceDescription});

  factory Match.fromJson(Map<String, dynamic> json) => Match(
        id: json['id'] as int,
        matchNumber: json['matchNumber'] as int,
        stage: json['stage'] as String,
        groupCode: json['groupCode'] as String?,
        homeTeamId: json['homeTeamId'] as int?,
        homeTeamName: json['homeTeamName'] as String?,
        homeTeamCountryCode: json['homeTeamCountryCode'] as String?,
        awayTeamId: json['awayTeamId'] as int?,
        awayTeamName: json['awayTeamName'] as String?,
        awayTeamCountryCode: json['awayTeamCountryCode'] as String?,
        homeScore: json['homeScore'] as int?,
        awayScore: json['awayScore'] as int?,
        status: json['status'] as String,
        kickOffUtc: DateTime.parse(json['kickOffUtc'] as String),
        venue: json['venue'] as String?,
        winnerTeamId: json['winnerTeamId'] as int?,
        winnerTeamName: json['winnerTeamName'] as String?,
        homeSourceDescription: json['homeSourceDescription'] as String?,
        awaySourceDescription: json['awaySourceDescription'] as String?,
      );

  bool get isFinished => status == 'Finished';
  bool get isScheduled => status == 'Scheduled';

  String get homeDisplay => homeTeamName ?? homeSourceDescription ?? 'TBD';
  String get awayDisplay => awayTeamName ?? awaySourceDescription ?? 'TBD';
}
