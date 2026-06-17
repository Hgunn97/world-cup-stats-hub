using Microsoft.EntityFrameworkCore;
using WorldCupStats.Api.Data;
using WorldCupStats.Api.DTOs;
using WorldCupStats.Api.Entities.Enums;

namespace WorldCupStats.Api.Services;

public class TeamStatsService(AppDbContext db) : ITeamStatsService
{
    public async Task<IReadOnlyList<TeamStatsDto>> GetTeamStatsAsync(CancellationToken cancellationToken)
    {
        var stats = await CalculateAllStatsAsync(cancellationToken);
        return stats.OrderByDescending(s => s.Points).ThenByDescending(s => s.GoalDifference).ToList();
    }

    public async Task<IReadOnlyList<TeamStatsDto>> GetTopScoringTeamsAsync(int limit, CancellationToken cancellationToken)
    {
        var stats = await CalculateAllStatsAsync(cancellationToken);
        return stats.OrderByDescending(s => s.GoalsScored).ThenByDescending(s => s.GoalsPerMatch).Take(limit).ToList();
    }

    public async Task<IReadOnlyList<TeamStatsDto>> GetMostConcededTeamsAsync(int limit, CancellationToken cancellationToken)
    {
        var stats = await CalculateAllStatsAsync(cancellationToken);
        return stats.OrderByDescending(s => s.GoalsConceded).Take(limit).ToList();
    }

    public async Task<IReadOnlyList<TeamStatsDto>> GetBestGoalDifferenceAsync(int limit, CancellationToken cancellationToken)
    {
        var stats = await CalculateAllStatsAsync(cancellationToken);
        return stats.OrderByDescending(s => s.GoalDifference).ThenByDescending(s => s.GoalsScored).Take(limit).ToList();
    }

    public async Task<IReadOnlyList<TeamStatsDto>> GetCleanSheetsAsync(int limit, CancellationToken cancellationToken)
    {
        var stats = await CalculateAllStatsAsync(cancellationToken);
        return stats.OrderByDescending(s => s.CleanSheets).ThenByDescending(s => s.MatchesPlayed).Take(limit).ToList();
    }

    public async Task<IReadOnlyList<HighScoringMatchDto>> GetHighestScoringMatchesAsync(int limit, CancellationToken cancellationToken)
    {
        var matches = await db.Matches
            .Include(m => m.HomeTeam)
            .Include(m => m.AwayTeam)
            .Where(m => m.Status == MatchStatus.Finished && m.HomeScore.HasValue && m.AwayScore.HasValue)
            .ToListAsync(cancellationToken);

        return matches
            .Select(m => new HighScoringMatchDto
            {
                MatchId = m.Id,
                Stage = m.Stage.ToString(),
                GroupCode = m.GroupCode,
                HomeTeamName = m.HomeTeam?.Name ?? m.HomeSourceDescription ?? "TBD",
                AwayTeamName = m.AwayTeam?.Name ?? m.AwaySourceDescription ?? "TBD",
                HomeScore = m.HomeScore!.Value,
                AwayScore = m.AwayScore!.Value,
                TotalGoals = m.HomeScore.Value + m.AwayScore.Value,
                KickOffUtc = m.KickOffUtc
            })
            .OrderByDescending(m => m.TotalGoals)
            .ThenByDescending(m => m.KickOffUtc)
            .Take(limit)
            .Select((m, i) => { m.Rank = i + 1; return m; })
            .ToList();
    }

    private async Task<List<TeamStatsDto>> CalculateAllStatsAsync(CancellationToken cancellationToken)
    {
        var teams = await db.Teams.ToListAsync(cancellationToken);
        var matches = await db.Matches
            .Where(m => m.Status == MatchStatus.Finished && m.HomeScore.HasValue && m.AwayScore.HasValue)
            .ToListAsync(cancellationToken);

        var stats = teams.ToDictionary(t => t.Id, t => new TeamStatsDto
        {
            TeamId = t.Id,
            TeamName = t.Name,
            GroupCode = t.GroupCode
        });

        foreach (var match in matches)
        {
            if (!match.HomeTeamId.HasValue || !match.AwayTeamId.HasValue) continue;

            var home = stats[match.HomeTeamId.Value];
            var away = stats[match.AwayTeamId.Value];

            home.MatchesPlayed++;
            away.MatchesPlayed++;
            home.GoalsScored += match.HomeScore!.Value;
            home.GoalsConceded += match.AwayScore!.Value;
            away.GoalsScored += match.AwayScore!.Value;
            away.GoalsConceded += match.HomeScore!.Value;

            if (match.AwayScore == 0) home.CleanSheets++;
            if (match.HomeScore == 0) away.CleanSheets++;
            if (match.HomeScore == 0) home.FailedToScore++;
            if (match.AwayScore == 0) away.FailedToScore++;

            if (match.HomeScore > match.AwayScore)
            {
                home.Wins++; home.Points += 3;
                away.Losses++;
            }
            else if (match.AwayScore > match.HomeScore)
            {
                away.Wins++; away.Points += 3;
                home.Losses++;
            }
            else
            {
                home.Draws++; home.Points++;
                away.Draws++; away.Points++;
            }
        }

        foreach (var s in stats.Values)
        {
            s.GoalDifference = s.GoalsScored - s.GoalsConceded;
            s.GoalsPerMatch = s.MatchesPlayed > 0 ? Math.Round((decimal)s.GoalsScored / s.MatchesPlayed, 2) : 0;
            s.GoalsConcededPerMatch = s.MatchesPlayed > 0 ? Math.Round((decimal)s.GoalsConceded / s.MatchesPlayed, 2) : 0;
        }

        return [.. stats.Values];
    }
}
