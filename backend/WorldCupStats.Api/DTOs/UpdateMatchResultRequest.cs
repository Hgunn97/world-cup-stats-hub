namespace WorldCupStats.Api.DTOs;

public class UpdateMatchResultRequest
{
    public int? HomeScore { get; set; }
    public int? AwayScore { get; set; }
    public string Status { get; set; } = string.Empty;
    public int? WinnerTeamId { get; set; }
}
