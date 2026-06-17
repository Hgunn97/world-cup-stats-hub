namespace WorldCupStats.Api.DTOs;

public class TournamentSummaryDto
{
    public int TotalMatches { get; set; }
    public int MatchesPlayed { get; set; }
    public int MatchesRemaining { get; set; }
    public int TotalGoals { get; set; }
    public decimal GoalsPerMatch { get; set; }
    public TeamStatSummary? TopScoringTeam { get; set; }
    public TeamStatSummary? MostConcededTeam { get; set; }
    public TeamStatSummary? BestGoalDifferenceTeam { get; set; }
    public TeamStatSummary? MostCleanSheetsTeam { get; set; }
    public HighScoringMatchSummary? HighestScoringMatch { get; set; }
}

public class TeamStatSummary
{
    public int TeamId { get; set; }
    public string TeamName { get; set; } = string.Empty;
    public int Value { get; set; }
}

public class HighScoringMatchSummary
{
    public int MatchId { get; set; }
    public string HomeTeamName { get; set; } = string.Empty;
    public string AwayTeamName { get; set; } = string.Empty;
    public int HomeScore { get; set; }
    public int AwayScore { get; set; }
    public int TotalGoals { get; set; }
}
