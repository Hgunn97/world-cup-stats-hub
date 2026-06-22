using System.Text.Json;
using System.Text.Json.Serialization;
using Microsoft.EntityFrameworkCore;
using WorldCupStats.Api.Entities;
using WorldCupStats.Api.Entities.Enums;

namespace WorldCupStats.Api.Data;

public static class SeedDataLoader
{
    public static async Task SeedAsync(AppDbContext db, IWebHostEnvironment env)
    {
        await db.Database.EnsureCreatedAsync();

        if (await db.Teams.AnyAsync()) return;

        var options = new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        };

        var teamsPath = Path.Combine(env.ContentRootPath, "SeedData", "teams.json");
        var matchesPath = Path.Combine(env.ContentRootPath, "SeedData", "matches.json");

        var teamsJson = await File.ReadAllTextAsync(teamsPath);
        var teams = JsonSerializer.Deserialize<List<Team>>(teamsJson, options)!;
        db.Teams.AddRange(teams);
        await db.SaveChangesAsync();

        var matchesJson = await File.ReadAllTextAsync(matchesPath);
        var matchSeeds = JsonSerializer.Deserialize<List<MatchSeedDto>>(matchesJson, options)!;

        foreach (var seed in matchSeeds)
        {
            db.Matches.Add(new Match
            {
                Id = seed.Id,
                MatchNumber = seed.MatchNumber,
                Stage = Enum.Parse<TournamentStage>(NormaliseStage(seed.Stage), ignoreCase: true),
                GroupCode = seed.GroupCode,
                HomeTeamId = seed.HomeTeamId,
                AwayTeamId = seed.AwayTeamId,
                HomeScore = seed.HomeScore,
                AwayScore = seed.AwayScore,
                Status = Enum.Parse<MatchStatus>(NormaliseStatus(seed.Status), ignoreCase: true),
                KickOffUtc = seed.KickOffUtc,
                Venue = seed.Venue,
                HomeSourceDescription = seed.HomeSourceDescription,
                AwaySourceDescription = seed.AwaySourceDescription,
                WinnerAdvancesToMatchNumber = seed.WinnerAdvancesToMatchNumber,
                WinnerAdvancesToSlot = seed.WinnerAdvancesToSlot,
                LoserAdvancesToMatchNumber = seed.LoserAdvancesToMatchNumber,
                LoserAdvancesToSlot = seed.LoserAdvancesToSlot,
            });
        }

        await db.SaveChangesAsync();
    }

    private static string NormaliseStatus(string value) => value.ToLowerInvariant() switch
    {
        "completed" or "complete" or "fulltime" or "full-time" or "ft" => "Finished",
        "inprogress" or "in_progress" or "live" or "ongoing" => "InProgress",
        "postponed" or "pp" => "Postponed",
        "cancelled" or "canceled" => "Cancelled",
        _ => value
    };

    private static string NormaliseStage(string value) => value.ToLowerInvariant() switch
    {
        "group" or "groups" or "group stage" or "groupstage" => "GroupStage",
        "roundof32" or "round of 32" or "r32" => "RoundOf32",
        "roundof16" or "round of 16" or "r16" => "RoundOf16",
        "quarterfinal" or "quarter-final" or "quarter final" or "qf" => "QuarterFinal",
        "semifinal" or "semi-final" or "semi final" or "sf" => "SemiFinal",
        "thirdplace" or "third place" or "third-place" or "3rdplace" => "ThirdPlacePlayoff",
        "final" => "Final",
        _ => value
    };

    private class MatchSeedDto
    {
        public int Id { get; set; }
        public int MatchNumber { get; set; }
        public string Stage { get; set; } = string.Empty;
        public string? GroupCode { get; set; }
        public int? HomeTeamId { get; set; }
        public int? AwayTeamId { get; set; }
        public int? HomeScore { get; set; }
        public int? AwayScore { get; set; }
        public string Status { get; set; } = "Scheduled";
        public DateTime KickOffUtc { get; set; }
        public string? Venue { get; set; }
        public string? HomeSourceDescription { get; set; }
        public string? AwaySourceDescription { get; set; }
        public int? WinnerAdvancesToMatchNumber { get; set; }
        public string? WinnerAdvancesToSlot { get; set; }
        public int? LoserAdvancesToMatchNumber { get; set; }
        public string? LoserAdvancesToSlot { get; set; }
    }
}
