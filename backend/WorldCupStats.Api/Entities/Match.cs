using WorldCupStats.Api.Entities.Enums;

namespace WorldCupStats.Api.Entities;

public class Match
{
    public int Id { get; set; }
    public int MatchNumber { get; set; }
    public TournamentStage Stage { get; set; }
    public string? GroupCode { get; set; }

    public int? HomeTeamId { get; set; }
    public Team? HomeTeam { get; set; }

    public int? AwayTeamId { get; set; }
    public Team? AwayTeam { get; set; }

    public int? HomeScore { get; set; }
    public int? AwayScore { get; set; }

    public MatchStatus Status { get; set; }
    public DateTime KickOffUtc { get; set; }
    public string? Venue { get; set; }

    public int? WinnerTeamId { get; set; }
    public Team? WinnerTeam { get; set; }

    public string? HomeSourceDescription { get; set; }
    public string? AwaySourceDescription { get; set; }

    // Knockout progression: where the winner of this match goes next
    public int? WinnerAdvancesToMatchNumber { get; set; }
    public string? WinnerAdvancesToSlot { get; set; }  // "home" | "away"

    // Semi-finals only: where the loser goes (3rd place match)
    public int? LoserAdvancesToMatchNumber { get; set; }
    public string? LoserAdvancesToSlot { get; set; }   // "home" | "away"
}
