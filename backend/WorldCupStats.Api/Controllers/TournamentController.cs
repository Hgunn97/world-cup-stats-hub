using Microsoft.AspNetCore.Mvc;
using WorldCupStats.Api.Services;

namespace WorldCupStats.Api.Controllers;

[ApiController]
[Route("api/tournament")]
public class TournamentController(ITournamentSummaryService summaryService) : ControllerBase
{
    [HttpGet("summary")]
    public async Task<IActionResult> GetSummary(CancellationToken cancellationToken)
    {
        var summary = await summaryService.GetSummaryAsync(cancellationToken);
        return Ok(summary);
    }
}
