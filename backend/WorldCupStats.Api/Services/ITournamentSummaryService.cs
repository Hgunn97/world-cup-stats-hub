using WorldCupStats.Api.DTOs;

namespace WorldCupStats.Api.Services;

public interface ITournamentSummaryService
{
    Task<TournamentSummaryDto> GetSummaryAsync(CancellationToken cancellationToken);
}
