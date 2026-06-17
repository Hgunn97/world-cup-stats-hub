using Microsoft.EntityFrameworkCore;
using WorldCupStats.Api.Data;
using WorldCupStats.Api.DTOs;
using WorldCupStats.Api.Entities.Enums;

namespace WorldCupStats.Api.Services;

public class WallChartService(AppDbContext db) : IWallChartService
{
    private static readonly TournamentStage[] KnockoutStages =
    [
        TournamentStage.RoundOf32,
        TournamentStage.RoundOf16,
        TournamentStage.QuarterFinal,
        TournamentStage.SemiFinal,
        TournamentStage.ThirdPlacePlayoff,
        TournamentStage.Final
    ];

    public async Task<WallChartDto> GetWallChartAsync(CancellationToken cancellationToken)
    {
        var matches = await db.Matches
            .Include(m => m.HomeTeam)
            .Include(m => m.AwayTeam)
            .Include(m => m.WinnerTeam)
            .Where(m => m.Stage != TournamentStage.GroupStage)
            .OrderBy(m => m.MatchNumber)
            .ToListAsync(cancellationToken);

        var stages = KnockoutStages.Select(stage => new WallChartStageDto
        {
            Stage = stage.ToString(),
            Matches = matches
                .Where(m => m.Stage == stage)
                .Select(m => new WallChartMatchDto
                {
                    MatchId = m.Id,
                    MatchNumber = m.MatchNumber,
                    HomeTeamId = m.HomeTeamId,
                    HomeTeamName = m.HomeTeam?.Name,
                    AwayTeamId = m.AwayTeamId,
                    AwayTeamName = m.AwayTeam?.Name,
                    HomeSourceDescription = m.HomeSourceDescription,
                    AwaySourceDescription = m.AwaySourceDescription,
                    HomeScore = m.HomeScore,
                    AwayScore = m.AwayScore,
                    WinnerTeamId = m.WinnerTeamId,
                    WinnerTeamName = m.WinnerTeam?.Name,
                    Status = m.Status.ToString(),
                    KickOffUtc = m.KickOffUtc
                })
                .ToList()
        }).ToList();

        return new WallChartDto { Stages = stages };
    }
}
