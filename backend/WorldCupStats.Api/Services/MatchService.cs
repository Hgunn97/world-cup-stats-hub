using Microsoft.EntityFrameworkCore;
using WorldCupStats.Api.Data;
using WorldCupStats.Api.DTOs;
using WorldCupStats.Api.Entities;
using WorldCupStats.Api.Entities.Enums;

namespace WorldCupStats.Api.Services;

public class MatchService(AppDbContext db) : IMatchService
{
    public async Task<IReadOnlyList<MatchDto>> GetMatchesAsync(MatchQuery query, CancellationToken cancellationToken)
    {
        var q = db.Matches
            .Include(m => m.HomeTeam)
            .Include(m => m.AwayTeam)
            .Include(m => m.WinnerTeam)
            .AsQueryable();

        if (!string.IsNullOrEmpty(query.Stage) && Enum.TryParse<TournamentStage>(query.Stage, true, out var stage))
            q = q.Where(m => m.Stage == stage);

        if (!string.IsNullOrEmpty(query.GroupCode))
            q = q.Where(m => m.GroupCode == query.GroupCode.ToUpper());

        if (query.Date.HasValue)
            q = q.Where(m => DateOnly.FromDateTime(m.KickOffUtc) == query.Date.Value);

        var matches = await q.OrderBy(m => m.KickOffUtc).ThenBy(m => m.MatchNumber).ToListAsync(cancellationToken);
        return matches.Select(ToDto).ToList();
    }

    public async Task<MatchDto?> GetMatchByIdAsync(int matchId, CancellationToken cancellationToken)
    {
        var match = await db.Matches
            .Include(m => m.HomeTeam)
            .Include(m => m.AwayTeam)
            .Include(m => m.WinnerTeam)
            .FirstOrDefaultAsync(m => m.Id == matchId, cancellationToken);

        return match is null ? null : ToDto(match);
    }

    public async Task<MatchDto?> UpdateResultAsync(int matchId, UpdateMatchResultRequest request, CancellationToken cancellationToken)
    {
        var match = await db.Matches
            .Include(m => m.HomeTeam)
            .Include(m => m.AwayTeam)
            .Include(m => m.WinnerTeam)
            .FirstOrDefaultAsync(m => m.Id == matchId, cancellationToken);

        if (match is null) return null;

        if (!Enum.TryParse<MatchStatus>(request.Status, true, out var status))
            throw new ArgumentException($"Invalid status: {request.Status}");

        match.HomeScore = request.HomeScore;
        match.AwayScore = request.AwayScore;
        match.Status = status;

        if (status == MatchStatus.Finished && match.Stage != TournamentStage.GroupStage)
        {
            if (request.WinnerTeamId.HasValue)
            {
                match.WinnerTeamId = request.WinnerTeamId;
            }
            else if (match.HomeScore.HasValue && match.AwayScore.HasValue)
            {
                if (match.HomeScore > match.AwayScore)
                    match.WinnerTeamId = match.HomeTeamId;
                else if (match.AwayScore > match.HomeScore)
                    match.WinnerTeamId = match.AwayTeamId;
                // draw: no automatic winner
            }
        }
        else if (status != MatchStatus.Finished)
        {
            match.WinnerTeamId = null;
        }

        await db.SaveChangesAsync(cancellationToken);

        await db.Entry(match).Reference(m => m.WinnerTeam).LoadAsync(cancellationToken);
        return ToDto(match);
    }

    public static MatchDto ToDto(Match m) => new()
    {
        Id = m.Id,
        MatchNumber = m.MatchNumber,
        Stage = m.Stage.ToString(),
        GroupCode = m.GroupCode,
        HomeTeamId = m.HomeTeamId,
        HomeTeamName = m.HomeTeam?.Name,
        AwayTeamId = m.AwayTeamId,
        AwayTeamName = m.AwayTeam?.Name,
        HomeScore = m.HomeScore,
        AwayScore = m.AwayScore,
        Status = m.Status.ToString(),
        KickOffUtc = m.KickOffUtc,
        Venue = m.Venue,
        WinnerTeamId = m.WinnerTeamId,
        WinnerTeamName = m.WinnerTeam?.Name,
        HomeSourceDescription = m.HomeSourceDescription,
        AwaySourceDescription = m.AwaySourceDescription
    };
}
