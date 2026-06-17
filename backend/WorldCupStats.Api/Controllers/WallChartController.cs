using Microsoft.AspNetCore.Mvc;
using WorldCupStats.Api.Services;

namespace WorldCupStats.Api.Controllers;

[ApiController]
[Route("api/wall-chart")]
public class WallChartController(IWallChartService wallChartService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetWallChart(CancellationToken cancellationToken)
    {
        var wallChart = await wallChartService.GetWallChartAsync(cancellationToken);
        return Ok(wallChart);
    }
}
