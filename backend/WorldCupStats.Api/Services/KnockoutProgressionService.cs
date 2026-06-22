using WorldCupStats.Api.Data;
using WorldCupStats.Api.Entities.Enums;

namespace WorldCupStats.Api.Services;

public class KnockoutProgressionService(AppDbContext db, IWebHostEnvironment env, IGroupTableService groupTableService): IKnockoutProgressionService
{
    public async Task Recalculate()
    {
        var knockoutMatches = db.Matches.Where(m => m.MatchNumber >= 73).ToList();
        var matchByNo = knockoutMatches.ToDictionary(m => m.MatchNumber);

        await FillRoundOf32(matchByNo);
        FillNextRound(knockoutMatches, matchByNo);
        await db.SaveChangesAsync();
    }

    private async Task FillRoundOf32(Dictionary<int, Entities.Match> matchByNo)
    {
        var groups = await groupTableService.GetAllGroupTablesAsync(CancellationToken.None);
        var groupMap = groups.ToDictionary(x => x.GroupCode);

        SetSlot(matchByNo, 73, groupMap["A"].Teams[1].TeamId, groupMap["B"].Teams[1].TeamId);
        SetSlot(matchByNo, 75, groupMap["F"].Teams[0].TeamId, groupMap["C"].Teams[1].TeamId);
        SetSlot(matchByNo, 76, groupMap["C"].Teams[0].TeamId, groupMap["F"].Teams[1].TeamId);
        SetSlot(matchByNo, 78, groupMap["E"].Teams[1].TeamId, groupMap["I"].Teams[1].TeamId);
        SetSlot(matchByNo, 83, groupMap["K"].Teams[1].TeamId, groupMap["L"].Teams[1].TeamId);
        SetSlot(matchByNo, 84, groupMap["H"].Teams[0].TeamId, groupMap["J"].Teams[1].TeamId);
        SetSlot(matchByNo, 86, groupMap["J"].Teams[0].TeamId, groupMap["H"].Teams[1].TeamId);
        SetSlot(matchByNo, 88, groupMap["D"].Teams[1].TeamId, groupMap["G"].Teams[1].TeamId);

        var thirdPlaced = groups
            .Where(g => g.Teams.Count >= 3)
            .Select(g => g.Teams[2])
            .ToList();

        var ranked = thirdPlaced
            .OrderByDescending(t => t.Points)
            .ThenByDescending(t => t.GoalDifference)
            .ThenByDescending(t => t.GoalsFor)
            .Take(8)
            .ToList();

        var thirdGroups = ranked.Select(x => x.GroupCode).OrderBy(x => x).ToList();
        var teams = ranked.ToDictionary(t => t.GroupCode, t => t.TeamId);

        var lookupCombo = await LookupCombination(thirdGroups);

        SetSlot(matchByNo, 74, groupMap["E"].Teams[0].TeamId, teams[lookupCombo["E"]]);
        SetSlot(matchByNo, 77, groupMap["I"].Teams[0].TeamId, teams[lookupCombo["I"]]);
        SetSlot(matchByNo, 79, groupMap["A"].Teams[0].TeamId, teams[lookupCombo["A"]]);
        SetSlot(matchByNo, 80, groupMap["L"].Teams[0].TeamId, teams[lookupCombo["L"]]);
        SetSlot(matchByNo, 81, groupMap["D"].Teams[0].TeamId, teams[lookupCombo["D"]]);
        SetSlot(matchByNo, 82, groupMap["G"].Teams[0].TeamId, teams[lookupCombo["G"]]);
        SetSlot(matchByNo, 85, groupMap["B"].Teams[0].TeamId, teams[lookupCombo["B"]]);
        SetSlot(matchByNo, 87, groupMap["K"].Teams[0].TeamId, teams[lookupCombo["K"]]);
    }

    private static void FillNextRound(List<Entities.Match> knockoutMatches, Dictionary<int, Entities.Match> matchByNo)
    {
        var finishedMatches = knockoutMatches.Where(m => m.Status == MatchStatus.Finished).ToList();

        foreach (var match in finishedMatches)
        {
            if (match.WinnerAdvancesToMatchNumber is not null)
            {
                var target = matchByNo[match.WinnerAdvancesToMatchNumber.Value];

                if (match.WinnerAdvancesToSlot == "home")
                    target.HomeTeamId = match.WinnerTeamId;
                else
                    target.AwayTeamId = match.WinnerTeamId;
            }

            if (match.LoserAdvancesToMatchNumber is not null)
            {
                var target = matchByNo[match.LoserAdvancesToMatchNumber.Value];
                var loserId = match.WinnerTeamId == match.HomeTeamId ? match.AwayTeamId : match.HomeTeamId;

                if (match.LoserAdvancesToSlot == "home")
                    target.HomeTeamId = loserId;
                else
                    target.AwayTeamId = loserId;
            }
        }
    }

    private static void SetSlot(Dictionary<int, Entities.Match> matchByNo, int matchNumber, int home, int away)
    {
        if (!matchByNo.TryGetValue(matchNumber, out var match))
            return;

        match.HomeTeamId = home;
        match.AwayTeamId = away;
    }

    private async Task<Dictionary<string, string>> LookupCombination(List<string> qualifyingGroups)
    {
        var thirdPlacePath = Path.Combine(env.ContentRootPath, "SeedData", "third_place_combinations.csv");
        var lines = await File.ReadAllLinesAsync(thirdPlacePath);
        var key = string.Concat(qualifyingGroups);

        foreach (var line in lines.Skip(1))
        {
            var cols = line.Split(',');
            var rowKey = string.Concat(cols[1..9]);

            if (rowKey == key)
            {
                return new Dictionary<string, string>
                {
                    { "A", cols[9][1..] },
                    { "B", cols[10][1..] },
                    { "D", cols[11][1..] },
                    { "E", cols[12][1..] },
                    { "G", cols[13][1..] },
                    { "I", cols[14][1..] },
                    { "K", cols[15][1..] },
                    { "L", cols[16][1..] },
                };
            }
        }

        throw new InvalidOperationException($"No third-place combination found for qualifying groups: {key}");
    }
}
