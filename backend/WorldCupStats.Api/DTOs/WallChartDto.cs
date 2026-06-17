namespace WorldCupStats.Api.DTOs;

public class WallChartDto
{
    public List<WallChartStageDto> Stages { get; set; } = [];
}

public class WallChartStageDto
{
    public string Stage { get; set; } = string.Empty;
    public List<WallChartMatchDto> Matches { get; set; } = [];
}

public class WallChartMatchDto
{
    public int MatchId { get; set; }
    public int MatchNumber { get; set; }
    public int? HomeTeamId { get; set; }
    public string? HomeTeamName { get; set; }
    public int? AwayTeamId { get; set; }
    public string? AwayTeamName { get; set; }
    public string? HomeSourceDescription { get; set; }
    public string? AwaySourceDescription { get; set; }
    public int? HomeScore { get; set; }
    public int? AwayScore { get; set; }
    public int? WinnerTeamId { get; set; }
    public string? WinnerTeamName { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime KickOffUtc { get; set; }
}
