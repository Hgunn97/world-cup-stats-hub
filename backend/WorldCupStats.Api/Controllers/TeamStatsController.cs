using Microsoft.AspNetCore.Mvc;
using WorldCupStats.Api.Services;

namespace WorldCupStats.Api.Controllers;

[ApiController]
[Route("api/stats")]
public class TeamStatsController(ITeamStatsService teamStatsService) : ControllerBase
{
    [HttpGet("teams")]
    public async Task<IActionResult> GetAllStats(CancellationToken cancellationToken)
    {
        var stats = await teamStatsService.GetTeamStatsAsync(cancellationToken);
        return Ok(new { lastUpdatedUtc = DateTime.UtcNow, items = stats });
    }

    [HttpGet("teams/top-scoring")]
    public async Task<IActionResult> GetTopScoring([FromQuery] int limit = 10, CancellationToken cancellationToken = default)
    {
        var stats = await teamStatsService.GetTopScoringTeamsAsync(limit, cancellationToken);
        return Ok(new { lastUpdatedUtc = DateTime.UtcNow, items = stats });
    }

    [HttpGet("teams/most-conceded")]
    public async Task<IActionResult> GetMostConceded([FromQuery] int limit = 10, CancellationToken cancellationToken = default)
    {
        var stats = await teamStatsService.GetMostConcededTeamsAsync(limit, cancellationToken);
        return Ok(new { lastUpdatedUtc = DateTime.UtcNow, items = stats });
    }

    [HttpGet("teams/best-goal-difference")]
    public async Task<IActionResult> GetBestGoalDifference([FromQuery] int limit = 10, CancellationToken cancellationToken = default)
    {
        var stats = await teamStatsService.GetBestGoalDifferenceAsync(limit, cancellationToken);
        return Ok(new { lastUpdatedUtc = DateTime.UtcNow, items = stats });
    }

    [HttpGet("teams/clean-sheets")]
    public async Task<IActionResult> GetCleanSheets([FromQuery] int limit = 10, CancellationToken cancellationToken = default)
    {
        var stats = await teamStatsService.GetCleanSheetsAsync(limit, cancellationToken);
        return Ok(new { lastUpdatedUtc = DateTime.UtcNow, items = stats });
    }

    [HttpGet("matches/highest-scoring")]
    public async Task<IActionResult> GetHighestScoringMatches([FromQuery] int limit = 10, CancellationToken cancellationToken = default)
    {
        var matches = await teamStatsService.GetHighestScoringMatchesAsync(limit, cancellationToken);
        return Ok(new { items = matches });
    }
}
