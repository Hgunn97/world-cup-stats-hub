namespace WorldCupStats.Api.DTOs;

public class HighScoringMatchDto
{
    public int Rank { get; set; }
    public int MatchId { get; set; }
    public string Stage { get; set; } = string.Empty;
    public string? GroupCode { get; set; }
    public string HomeTeamName { get; set; } = string.Empty;
    public string AwayTeamName { get; set; } = string.Empty;
    public int HomeScore { get; set; }
    public int AwayScore { get; set; }
    public int TotalGoals { get; set; }
    public DateTime KickOffUtc { get; set; }
}
