using WorldCupStats.Api.DTOs;

namespace WorldCupStats.Api.Services;

public interface ITeamStatsService
{
    Task<IReadOnlyList<TeamStatsDto>> GetTeamStatsAsync(CancellationToken cancellationToken);
    Task<IReadOnlyList<TeamStatsDto>> GetTopScoringTeamsAsync(int limit, CancellationToken cancellationToken);
    Task<IReadOnlyList<TeamStatsDto>> GetMostConcededTeamsAsync(int limit, CancellationToken cancellationToken);
    Task<IReadOnlyList<TeamStatsDto>> GetBestGoalDifferenceAsync(int limit, CancellationToken cancellationToken);
    Task<IReadOnlyList<TeamStatsDto>> GetCleanSheetsAsync(int limit, CancellationToken cancellationToken);
    Task<IReadOnlyList<HighScoringMatchDto>> GetHighestScoringMatchesAsync(int limit, CancellationToken cancellationToken);
}
