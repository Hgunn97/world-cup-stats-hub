class TeamStatSummary {
  final int teamId;
  final String teamName;
  final int value;

  TeamStatSummary({required this.teamId, required this.teamName, required this.value});

  factory TeamStatSummary.fromJson(Map<String, dynamic> json) => TeamStatSummary(
        teamId: json['teamId'] as int,
        teamName: json['teamName'] as String,
        value: json['value'] as int,
      );
}

class HighScoringMatchSummary {
  final int matchId;
  final String homeTeamName;
  final String awayTeamName;
  final int homeScore;
  final int awayScore;
  final int totalGoals;

  HighScoringMatchSummary(
      {required this.matchId,
      required this.homeTeamName,
      required this.awayTeamName,
      required this.homeScore,
      required this.awayScore,
      required this.totalGoals});

  factory HighScoringMatchSummary.fromJson(Map<String, dynamic> json) =>
      HighScoringMatchSummary(
        matchId: json['matchId'] as int,
        homeTeamName: json['homeTeamName'] as String,
        awayTeamName: json['awayTeamName'] as String,
        homeScore: json['homeScore'] as int,
        awayScore: json['awayScore'] as int,
        totalGoals: json['totalGoals'] as int,
      );
}

class TournamentSummary {
  final int totalMatches;
  final int matchesPlayed;
  final int matchesRemaining;
  final int totalGoals;
  final double goalsPerMatch;
  final TeamStatSummary? topScoringTeam;
  final TeamStatSummary? mostConcededTeam;
  final TeamStatSummary? bestGoalDifferenceTeam;
  final TeamStatSummary? mostCleanSheetsTeam;
  final HighScoringMatchSummary? highestScoringMatch;

  TournamentSummary(
      {required this.totalMatches,
      required this.matchesPlayed,
      required this.matchesRemaining,
      required this.totalGoals,
      required this.goalsPerMatch,
      this.topScoringTeam,
      this.mostConcededTeam,
      this.bestGoalDifferenceTeam,
      this.mostCleanSheetsTeam,
      this.highestScoringMatch});

  factory TournamentSummary.fromJson(Map<String, dynamic> json) =>
      TournamentSummary(
        totalMatches: json['totalMatches'] as int,
        matchesPlayed: json['matchesPlayed'] as int,
        matchesRemaining: json['matchesRemaining'] as int,
        totalGoals: json['totalGoals'] as int,
        goalsPerMatch: (json['goalsPerMatch'] as num).toDouble(),
        topScoringTeam: json['topScoringTeam'] == null
            ? null
            : TeamStatSummary.fromJson(json['topScoringTeam'] as Map<String, dynamic>),
        mostConcededTeam: json['mostConcededTeam'] == null
            ? null
            : TeamStatSummary.fromJson(json['mostConcededTeam'] as Map<String, dynamic>),
        bestGoalDifferenceTeam: json['bestGoalDifferenceTeam'] == null
            ? null
            : TeamStatSummary.fromJson(json['bestGoalDifferenceTeam'] as Map<String, dynamic>),
        mostCleanSheetsTeam: json['mostCleanSheetsTeam'] == null
            ? null
            : TeamStatSummary.fromJson(json['mostCleanSheetsTeam'] as Map<String, dynamic>),
        highestScoringMatch: json['highestScoringMatch'] == null
            ? null
            : HighScoringMatchSummary.fromJson(
                json['highestScoringMatch'] as Map<String, dynamic>),
      );
}
