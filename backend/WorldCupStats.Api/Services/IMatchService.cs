using WorldCupStats.Api.DTOs;

namespace WorldCupStats.Api.Services;

public interface IMatchService
{
    Task<IReadOnlyList<MatchDto>> GetMatchesAsync(MatchQuery query, CancellationToken cancellationToken);
    Task<MatchDto?> GetMatchByIdAsync(int matchId, CancellationToken cancellationToken);
    Task<MatchDto?> UpdateResultAsync(int matchId, UpdateMatchResultRequest request, CancellationToken cancellationToken);
}
