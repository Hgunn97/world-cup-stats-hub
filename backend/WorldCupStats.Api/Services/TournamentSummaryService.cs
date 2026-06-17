using Microsoft.EntityFrameworkCore;
using WorldCupStats.Api.Data;
using WorldCupStats.Api.DTOs;
using WorldCupStats.Api.Entities.Enums;

namespace WorldCupStats.Api.Services;

public class TournamentSummaryService(AppDbContext db, ITeamStatsService teamStatsService) : ITournamentSummaryService
{
    public async Task<TournamentSummaryDto> GetSummaryAsync(CancellationToken cancellationToken)
    {
        var totalMatches = await db.Matches.CountAsync(cancellationToken);
        var matchesPlayed = await db.Matches.CountAsync(m => m.Status == MatchStatus.Finished, cancellationToken);

        var finishedMatches = await db.Matches
            .Include(m => m.HomeTeam)
            .Include(m => m.AwayTeam)
            .Where(m => m.Status == MatchStatus.Finished && m.HomeScore.HasValue && m.AwayScore.HasValue)
            .ToListAsync(cancellationToken);

        var totalGoals = finishedMatches.Sum(m => m.HomeScore!.Value + m.AwayScore!.Value);
        var goalsPerMatch = matchesPlayed > 0 ? Math.Round((decimal)totalGoals / matchesPlayed, 2) : 0;

        var teamStats = await teamStatsService.GetTeamStatsAsync(cancellationToken);

        TeamStatSummary? topScoring = null;
        TeamStatSummary? mostConceded = null;
        TeamStatSummary? bestGD = null;
        TeamStatSummary? mostCleanSheets = null;
        HighScoringMatchSummary? highestScoring = null;

        if (teamStats.Any(s => s.MatchesPlayed > 0))
        {
            var top = teamStats.OrderByDescending(s => s.GoalsScored).First();
            topScoring = new TeamStatSummary { TeamId = top.TeamId, TeamName = top.TeamName, Value = top.GoalsScored };

            var conceded = teamStats.OrderByDescending(s => s.GoalsConceded).First();
            mostConceded = new TeamStatSummary { TeamId = conceded.TeamId, TeamName = conceded.TeamName, Value = conceded.GoalsConceded };

            var gd = teamStats.OrderByDescending(s => s.GoalDifference).First();
            bestGD = new TeamStatSummary { TeamId = gd.TeamId, TeamName = gd.TeamName, Value = gd.GoalDifference };

            var cs = teamStats.OrderByDescending(s => s.CleanSheets).First();
            mostCleanSheets = new TeamStatSummary { TeamId = cs.TeamId, TeamName = cs.TeamName, Value = cs.CleanSheets };
        }

        if (finishedMatches.Any())
        {
            var best = finishedMatches.OrderByDescending(m => m.HomeScore!.Value + m.AwayScore!.Value).First();
            highestScoring = new HighScoringMatchSummary
            {
                MatchId = best.Id,
                HomeTeamName = best.HomeTeam?.Name ?? "TBD",
                AwayTeamName = best.AwayTeam?.Name ?? "TBD",
                HomeScore = best.HomeScore!.Value,
                AwayScore = best.AwayScore!.Value,
                TotalGoals = best.HomeScore.Value + best.AwayScore.Value
            };
        }

        return new TournamentSummaryDto
        {
            TotalMatches = totalMatches,
            MatchesPlayed = matchesPlayed,
            MatchesRemaining = totalMatches - matchesPlayed,
            TotalGoals = totalGoals,
            GoalsPerMatch = goalsPerMatch,
            TopScoringTeam = topScoring,
            MostConcededTeam = mostConceded,
            BestGoalDifferenceTeam = bestGD,
            MostCleanSheetsTeam = mostCleanSheets,
            HighestScoringMatch = highestScoring
        };
    }
}
