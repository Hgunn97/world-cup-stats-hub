using System.Text.Json;
using FluentAssertions;

namespace WorldCupStats.Tests;

public class SeedDataValidationTests
{
    private static readonly string _seedDir =
        Path.Combine(AppContext.BaseDirectory, "SeedData");

    private static JsonElement[] LoadArray(string fileName)
    {
        var path = Path.Combine(_seedDir, fileName);
        var json = File.ReadAllText(path);
        return JsonSerializer.Deserialize<JsonElement[]>(json)!;
    }

    [Fact]
    public void Teams_Count_Is_48()
    {
        var teams = LoadArray("teams.json");
        teams.Should().HaveCount(48, "the tournament has exactly 48 teams");
    }

    [Fact]
    public void Teams_Have_Unique_Ids()
    {
        var teams = LoadArray("teams.json");
        var ids = teams.Select(t => t.GetProperty("id").GetInt32()).ToList();
        ids.Should().OnlyHaveUniqueItems("each team must have a unique id");
    }

    [Fact]
    public void Teams_Are_Spread_Across_12_Groups()
    {
        var teams = LoadArray("teams.json");
        var groups = teams.Select(t => t.GetProperty("groupCode").GetString()).Distinct().ToList();
        groups.Should().HaveCount(12, "the tournament has 12 groups A–L");
    }

    [Fact]
    public void Matches_Count_Is_104()
    {
        var matches = LoadArray("matches.json");
        matches.Should().HaveCount(104, "the tournament has exactly 104 matches");
    }

    [Fact]
    public void GroupStage_Matches_Count_Is_72()
    {
        var matches = LoadArray("matches.json");
        var groupMatches = matches.Where(m =>
            m.GetProperty("stage").GetString() == "GroupStage").ToList();
        groupMatches.Should().HaveCount(72, "12 groups × 6 matches = 72 group stage matches");
    }

    [Fact]
    public void Knockout_Matches_Count_Is_32()
    {
        var matches = LoadArray("matches.json");
        var knockoutMatches = matches.Where(m =>
            m.GetProperty("stage").GetString() != "GroupStage").ToList();
        knockoutMatches.Should().HaveCount(32, "the knockout rounds have exactly 32 matches");
    }

    [Fact]
    public void Each_Team_Plays_Exactly_3_Group_Games()
    {
        var teams = LoadArray("teams.json");
        var matches = LoadArray("matches.json");

        var teamIds = teams.Select(t => t.GetProperty("id").GetInt32()).ToHashSet();

        var groupMatches = matches.Where(m =>
            m.GetProperty("stage").GetString() == "GroupStage").ToList();

        var appearances = new Dictionary<int, int>();
        foreach (var m in groupMatches)
        {
            if (m.TryGetProperty("homeTeamId", out var home) && home.ValueKind != JsonValueKind.Null)
            {
                var id = home.GetInt32();
                appearances[id] = appearances.GetValueOrDefault(id) + 1;
            }
            if (m.TryGetProperty("awayTeamId", out var away) && away.ValueKind != JsonValueKind.Null)
            {
                var id = away.GetInt32();
                appearances[id] = appearances.GetValueOrDefault(id) + 1;
            }
        }

        foreach (var teamId in teamIds)
        {
            appearances.GetValueOrDefault(teamId).Should().Be(3,
                $"team {teamId} should play exactly 3 group stage matches");
        }
    }

    [Fact]
    public void All_Group_Match_Team_Ids_Are_Valid()
    {
        var teams = LoadArray("teams.json");
        var matches = LoadArray("matches.json");

        var validIds = teams.Select(t => t.GetProperty("id").GetInt32()).ToHashSet();

        var groupMatches = matches.Where(m =>
            m.GetProperty("stage").GetString() == "GroupStage").ToList();

        foreach (var m in groupMatches)
        {
            if (m.TryGetProperty("homeTeamId", out var home) && home.ValueKind != JsonValueKind.Null)
                validIds.Should().Contain(home.GetInt32(),
                    $"homeTeamId {home.GetInt32()} in match {m.GetProperty("id").GetInt32()} must exist in teams.json");

            if (m.TryGetProperty("awayTeamId", out var away) && away.ValueKind != JsonValueKind.Null)
                validIds.Should().Contain(away.GetInt32(),
                    $"awayTeamId {away.GetInt32()} in match {m.GetProperty("id").GetInt32()} must exist in teams.json");
        }
    }

    [Fact]
    public void Matches_Have_Unique_Numbers()
    {
        var matches = LoadArray("matches.json");
        var numbers = matches.Select(m => m.GetProperty("matchNumber").GetInt32()).ToList();
        numbers.Should().OnlyHaveUniqueItems("each match must have a unique matchNumber");
    }
}
