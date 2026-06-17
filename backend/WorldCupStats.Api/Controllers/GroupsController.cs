using Microsoft.AspNetCore.Mvc;
using WorldCupStats.Api.Services;

namespace WorldCupStats.Api.Controllers;

[ApiController]
[Route("api/groups")]
public class GroupsController(IGroupTableService groupTableService) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAllGroups(CancellationToken cancellationToken)
    {
        var tables = await groupTableService.GetAllGroupTablesAsync(cancellationToken);
        return Ok(tables);
    }

    [HttpGet("{groupCode}/table")]
    public async Task<IActionResult> GetGroupTable(string groupCode, CancellationToken cancellationToken)
    {
        var table = await groupTableService.GetGroupTableAsync(groupCode, cancellationToken);
        if (table is null)
            return Problem(title: "Group not found", detail: $"No group was found with code '{groupCode.ToUpper()}'.", statusCode: 404);
        return Ok(table);
    }
}
