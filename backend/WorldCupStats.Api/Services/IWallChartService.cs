using WorldCupStats.Api.DTOs;

namespace WorldCupStats.Api.Services;

public interface IWallChartService
{
    Task<WallChartDto> GetWallChartAsync(CancellationToken cancellationToken);
}
