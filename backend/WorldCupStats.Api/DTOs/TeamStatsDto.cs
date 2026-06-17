namespace WorldCupStats.Api.DTOs;

public class TeamStatsDto
{
    public int Rank { get; set; }
    public int TeamId { get; set; }
    public string TeamName { get; set; } = string.Empty;
    public string? GroupCode { get; set; }
    public int MatchesPlayed { get; set; }
    public int Wins { get; set; }
    public int Draws { get; set; }
    public int Losses { get; set; }
    public int GoalsScored { get; set; }
    public int GoalsConceded { get; set; }
    public int GoalDifference { get; set; }
    public int Points { get; set; }
    public int CleanSheets { get; set; }
    public int FailedToScore { get; set; }
    public decimal GoalsPerMatch { get; set; }
    public decimal GoalsConcededPerMatch { get; set; }
}
