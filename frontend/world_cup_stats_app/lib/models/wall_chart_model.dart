class WallChartMatch {
  final int matchId;
  final int matchNumber;
  final int? homeTeamId;
  final String? homeTeamName;
  final int? awayTeamId;
  final String? awayTeamName;
  final String? homeSourceDescription;
  final String? awaySourceDescription;
  final int? homeScore;
  final int? awayScore;
  final int? winnerTeamId;
  final String? winnerTeamName;
  final String status;
  final DateTime kickOffUtc;

  WallChartMatch(
      {required this.matchId,
      required this.matchNumber,
      this.homeTeamId,
      this.homeTeamName,
      this.awayTeamId,
      this.awayTeamName,
      this.homeSourceDescription,
      this.awaySourceDescription,
      this.homeScore,
      this.awayScore,
      this.winnerTeamId,
      this.winnerTeamName,
      required this.status,
      required this.kickOffUtc});

  factory WallChartMatch.fromJson(Map<String, dynamic> json) => WallChartMatch(
        matchId: json['matchId'] as int,
        matchNumber: json['matchNumber'] as int,
        homeTeamId: json['homeTeamId'] as int?,
        homeTeamName: json['homeTeamName'] as String?,
        awayTeamId: json['awayTeamId'] as int?,
        awayTeamName: json['awayTeamName'] as String?,
        homeSourceDescription: json['homeSourceDescription'] as String?,
        awaySourceDescription: json['awaySourceDescription'] as String?,
        homeScore: json['homeScore'] as int?,
        awayScore: json['awayScore'] as int?,
        winnerTeamId: json['winnerTeamId'] as int?,
        winnerTeamName: json['winnerTeamName'] as String?,
        status: json['status'] as String,
        kickOffUtc: DateTime.parse(json['kickOffUtc'] as String),
      );

  String get homeDisplay => homeTeamName ?? homeSourceDescription ?? 'TBD';
  String get awayDisplay => awayTeamName ?? awaySourceDescription ?? 'TBD';
}

class WallChartStage {
  final String stage;
  final List<WallChartMatch> matches;

  WallChartStage({required this.stage, required this.matches});

  factory WallChartStage.fromJson(Map<String, dynamic> json) => WallChartStage(
        stage: json['stage'] as String,
        matches: (json['matches'] as List<dynamic>)
            .map((e) => WallChartMatch.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  String get displayName {
    switch (stage) {
      case 'RoundOf32':
        return 'Round of 32';
      case 'RoundOf16':
        return 'Round of 16';
      case 'QuarterFinal':
        return 'Quarter-finals';
      case 'SemiFinal':
        return 'Semi-finals';
      case 'ThirdPlacePlayoff':
        return 'Third Place';
      case 'Final':
        return 'Final';
      default:
        return stage;
    }
  }
}

class WallChart {
  final List<WallChartStage> stages;

  WallChart({required this.stages});

  factory WallChart.fromJson(Map<String, dynamic> json) => WallChart(
        stages: (json['stages'] as List<dynamic>)
            .map((e) => WallChartStage.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
