class TeamStats {
  final int rank;
  final int teamId;
  final String teamName;
  final String? groupCode;
  final int matchesPlayed;
  final int wins;
  final int draws;
  final int losses;
  final int goalsScored;
  final int goalsConceded;
  final int goalDifference;
  final int points;
  final int cleanSheets;
  final int failedToScore;
  final double goalsPerMatch;
  final double goalsConcededPerMatch;

  TeamStats(
      {required this.rank,
      required this.teamId,
      required this.teamName,
      this.groupCode,
      required this.matchesPlayed,
      required this.wins,
      required this.draws,
      required this.losses,
      required this.goalsScored,
      required this.goalsConceded,
      required this.goalDifference,
      required this.points,
      required this.cleanSheets,
      required this.failedToScore,
      required this.goalsPerMatch,
      required this.goalsConcededPerMatch});

  factory TeamStats.fromJson(Map<String, dynamic> json) => TeamStats(
        rank: json['rank'] as int? ?? 0,
        teamId: json['teamId'] as int,
        teamName: json['teamName'] as String,
        groupCode: json['groupCode'] as String?,
        matchesPlayed: json['matchesPlayed'] as int,
        wins: json['wins'] as int,
        draws: json['draws'] as int,
        losses: json['losses'] as int,
        goalsScored: json['goalsScored'] as int,
        goalsConceded: json['goalsConceded'] as int,
        goalDifference: json['goalDifference'] as int,
        points: json['points'] as int,
        cleanSheets: json['cleanSheets'] as int,
        failedToScore: json['failedToScore'] as int,
        goalsPerMatch: (json['goalsPerMatch'] as num).toDouble(),
        goalsConcededPerMatch: (json['goalsConcededPerMatch'] as num).toDouble(),
      );
}

class HighScoringMatch {
  final int rank;
  final int matchId;
  final String stage;
  final String? groupCode;
  final String homeTeamName;
  final String awayTeamName;
  final int homeScore;
  final int awayScore;
  final int totalGoals;
  final DateTime kickOffUtc;

  HighScoringMatch(
      {required this.rank,
      required this.matchId,
      required this.stage,
      this.groupCode,
      required this.homeTeamName,
      required this.awayTeamName,
      required this.homeScore,
      required this.awayScore,
      required this.totalGoals,
      required this.kickOffUtc});

  factory HighScoringMatch.fromJson(Map<String, dynamic> json) => HighScoringMatch(
        rank: json['rank'] as int,
        matchId: json['matchId'] as int,
        stage: json['stage'] as String,
        groupCode: json['groupCode'] as String?,
        homeTeamName: json['homeTeamName'] as String,
        awayTeamName: json['awayTeamName'] as String,
        homeScore: json['homeScore'] as int,
        awayScore: json['awayScore'] as int,
        totalGoals: json['totalGoals'] as int,
        kickOffUtc: DateTime.parse(json['kickOffUtc'] as String),
      );
}
