using Microsoft.AspNetCore.Mvc;
using WorldCupStats.Api.Services;

namespace WorldCupStats.Api.Controllers;

[ApiController]
[Route("api/knockout")]
public class KnockoutController(IKnockoutProgressionService knockoutProgressionService) : ControllerBase
{
    [HttpPost("recalculate")]
    public async Task<IActionResult> Recalculate()
    {
        await knockoutProgressionService.Recalculate();
        return Ok(new { message = "Knockout bracket recalculated." });
    }
}
