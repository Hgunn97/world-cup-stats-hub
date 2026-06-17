using WorldCupStats.Api.DTOs;

namespace WorldCupStats.Api.Services;

public interface IGroupTableService
{
    Task<IReadOnlyList<GroupTableDto>> GetAllGroupTablesAsync(CancellationToken cancellationToken);
    Task<GroupTableDto?> GetGroupTableAsync(string groupCode, CancellationToken cancellationToken);
}
