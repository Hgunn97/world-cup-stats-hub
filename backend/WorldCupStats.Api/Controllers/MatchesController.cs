using Microsoft.AspNetCore.Mvc;
using WorldCupStats.Api.DTOs;
using WorldCupStats.Api.Services;

namespace WorldCupStats.Api.Controllers;

[ApiController]
[Route("api/matches")]
public class MatchesController(IMatchService matchService, IWebHostEnvironment env) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetMatches([FromQuery] MatchQuery query, CancellationToken cancellationToken)
    {
        var matches = await matchService.GetMatchesAsync(query, cancellationToken);
        return Ok(matches);
    }

    [HttpGet("{matchId:int}")]
    public async Task<IActionResult> GetMatch(int matchId, CancellationToken cancellationToken)
    {
        var match = await matchService.GetMatchByIdAsync(matchId, cancellationToken);
        if (match is null)
            return Problem(title: "Match not found", detail: $"No match was found with id {matchId}.", statusCode: 404);
        return Ok(match);
    }

    [HttpPut("{matchId:int}/result")]
    public async Task<IActionResult> UpdateResult(int matchId, [FromBody] UpdateMatchResultRequest request, CancellationToken cancellationToken)
    {
        if (env.IsProduction())
            return StatusCode(403, new { error = "Result updates are disabled in production." });

        if (request.HomeScore.HasValue && request.HomeScore < 0)
            return Problem(title: "Invalid score", detail: "Home score must be 0 or greater.", statusCode: 400);

        if (request.AwayScore.HasValue && request.AwayScore < 0)
            return Problem(title: "Invalid score", detail: "Away score must be 0 or greater.", statusCode: 400);

        if (request.Status.Equals("Finished", StringComparison.OrdinalIgnoreCase) &&
            (!request.HomeScore.HasValue || !request.AwayScore.HasValue))
            return Problem(title: "Scores required", detail: "Both scores must be provided when status is Finished.", statusCode: 400);

        try
        {
            var match = await matchService.UpdateResultAsync(matchId, request, cancellationToken);
            if (match is null)
                return Problem(title: "Match not found", detail: $"No match was found with id {matchId}.", statusCode: 404);
            return Ok(match);
        }
        catch (ArgumentException ex)
        {
            return Problem(title: "Invalid request", detail: ex.Message, statusCode: 400);
        }
    }
}
