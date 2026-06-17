using Microsoft.EntityFrameworkCore;
using WorldCupStats.Api.Data;
using WorldCupStats.Api.DTOs;
using WorldCupStats.Api.Entities;
using WorldCupStats.Api.Entities.Enums;

namespace WorldCupStats.Api.Services;

public class GroupTableService(AppDbContext db) : IGroupTableService
{
    public async Task<IReadOnlyList<GroupTableDto>> GetAllGroupTablesAsync(CancellationToken cancellationToken)
    {
        var groups = await db.Teams
            .Where(t => t.GroupCode != null)
            .Select(t => t.GroupCode!)
            .Distinct()
            .OrderBy(g => g)
            .ToListAsync(cancellationToken);

        var result = new List<GroupTableDto>();
        foreach (var group in groups)
        {
            var table = await BuildGroupTableAsync(group, cancellationToken);
            result.Add(table);
        }
        return result;
    }

    public async Task<GroupTableDto?> GetGroupTableAsync(string groupCode, CancellationToken cancellationToken)
    {
        var code = groupCode.ToUpper();
        var exists = await db.Teams.AnyAsync(t => t.GroupCode == code, cancellationToken);
        if (!exists) return null;
        return await BuildGroupTableAsync(code, cancellationToken);
    }

    private async Task<GroupTableDto> BuildGroupTableAsync(string groupCode, CancellationToken cancellationToken)
    {
        var teams = await db.Teams
            .Where(t => t.GroupCode == groupCode)
            .ToListAsync(cancellationToken);

        var matches = await db.Matches
            .Where(m => m.GroupCode == groupCode && m.Stage == TournamentStage.GroupStage && m.Status == MatchStatus.Finished)
            .ToListAsync(cancellationToken);

        var rows = teams.ToDictionary(t => t.Id, t => new GroupTableRowDto
        {
            TeamId = t.Id,
            TeamName = t.Name,
            GroupCode = groupCode
        });

        foreach (var match in matches)
        {
            if (!match.HomeTeamId.HasValue || !match.AwayTeamId.HasValue) continue;
            if (!match.HomeScore.HasValue || !match.AwayScore.HasValue) continue;

            var home = rows[match.HomeTeamId.Value];
            var away = rows[match.AwayTeamId.Value];

            home.Played++;
            away.Played++;
            home.GoalsFor += match.HomeScore.Value;
            home.GoalsAgainst += match.AwayScore.Value;
            away.GoalsFor += match.AwayScore.Value;
            away.GoalsAgainst += match.HomeScore.Value;

            if (match.HomeScore > match.AwayScore)
            {
                home.Won++; home.Points += 3;
                away.Lost++;
            }
            else if (match.AwayScore > match.HomeScore)
            {
                away.Won++; away.Points += 3;
                home.Lost++;
            }
            else
            {
                home.Drawn++; home.Points++;
                away.Drawn++; away.Points++;
            }
        }

        foreach (var row in rows.Values)
            row.GoalDifference = row.GoalsFor - row.GoalsAgainst;

        // TODO: Add full FIFA tie-breaker rules (head-to-head, disciplinary points) in a future MVP
        var sorted = rows.Values
            .OrderByDescending(r => r.Points)
            .ThenByDescending(r => r.GoalDifference)
            .ThenByDescending(r => r.GoalsFor)
            .ThenBy(r => r.TeamName)
            .ToList();

        for (int i = 0; i < sorted.Count; i++)
            sorted[i].Position = i + 1;

        return new GroupTableDto { GroupCode = groupCode, Teams = sorted };
    }
}
