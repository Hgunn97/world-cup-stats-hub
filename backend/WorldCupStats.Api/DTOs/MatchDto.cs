using WorldCupStats.Api.Entities.Enums;

namespace WorldCupStats.Api.DTOs;

public class MatchDto
{
    public int Id { get; set; }
    public int MatchNumber { get; set; }
    public string Stage { get; set; } = string.Empty;
    public string? GroupCode { get; set; }
    public int? HomeTeamId { get; set; }
    public string? HomeTeamName { get; set; }
    public string? HomeTeamCountryCode { get; set; }
    public int? AwayTeamId { get; set; }
    public string? AwayTeamName { get; set; }
    public string? AwayTeamCountryCode { get; set; }
    public int? HomeScore { get; set; }
    public int? AwayScore { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime KickOffUtc { get; set; }
    public string? Venue { get; set; }
    public int? WinnerTeamId { get; set; }
    public string? WinnerTeamName { get; set; }
    public string? HomeSourceDescription { get; set; }
    public string? AwaySourceDescription { get; set; }
}
