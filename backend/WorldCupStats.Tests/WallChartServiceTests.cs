using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using WorldCupStats.Api.Data;
using WorldCupStats.Api.Entities;
using WorldCupStats.Api.Entities.Enums;
using WorldCupStats.Api.Services;

namespace WorldCupStats.Tests;

public class WallChartServiceTests : IDisposable
{
    private readonly AppDbContext _db;
    private readonly WallChartService _service;

    public WallChartServiceTests()
    {
        var opts = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        _db = new AppDbContext(opts);
        _service = new WallChartService(_db);

        _db.Teams.AddRange(
            new Team { Id = 1, Name = "TeamA", CountryCode = "AAA" },
            new Team { Id = 2, Name = "TeamB", CountryCode = "BBB" }
        );
        _db.Matches.AddRange(
            new Match { Id = 73, MatchNumber = 73, Stage = TournamentStage.RoundOf32, Status = MatchStatus.Scheduled, KickOffUtc = DateTime.UtcNow, HomeSourceDescription = "Winner Group A", AwaySourceDescription = "Runner-up Group B" },
            new Match { Id = 89, MatchNumber = 89, Stage = TournamentStage.RoundOf16, Status = MatchStatus.Scheduled, KickOffUtc = DateTime.UtcNow, HomeSourceDescription = "Winner Match 73", AwaySourceDescription = "Winner Match 74" },
            new Match { Id = 97, MatchNumber = 97, Stage = TournamentStage.QuarterFinal, Status = MatchStatus.Scheduled, KickOffUtc = DateTime.UtcNow, HomeSourceDescription = "Winner Match 89", AwaySourceDescription = "Winner Match 90" },
            new Match { Id = 101, MatchNumber = 101, Stage = TournamentStage.SemiFinal, Status = MatchStatus.Scheduled, KickOffUtc = DateTime.UtcNow, HomeSourceDescription = "Winner Match 97", AwaySourceDescription = "Winner Match 98" },
            new Match { Id = 103, MatchNumber = 103, Stage = TournamentStage.ThirdPlacePlayoff, Status = MatchStatus.Scheduled, KickOffUtc = DateTime.UtcNow, HomeSourceDescription = "Loser SF1", AwaySourceDescription = "Loser SF2" },
            new Match { Id = 104, MatchNumber = 104, Stage = TournamentStage.Final, Status = MatchStatus.Scheduled, KickOffUtc = DateTime.UtcNow, HomeSourceDescription = "Winner SF1", AwaySourceDescription = "Winner SF2" },
            new Match { Id = 105, MatchNumber = 105, Stage = TournamentStage.RoundOf32, HomeTeamId = 1, AwayTeamId = 2, HomeScore = 3, AwayScore = 1, WinnerTeamId = 1, Status = MatchStatus.Finished, KickOffUtc = DateTime.UtcNow }
        );
        _db.SaveChanges();
    }

    [Fact]
    public async Task Stages_AreReturnedInCorrectOrder()
    {
        var chart = await _service.GetWallChartAsync(default);
        chart.Stages.Select(s => s.Stage).Should().ContainInOrder(
            "RoundOf32", "RoundOf16", "QuarterFinal", "SemiFinal", "ThirdPlacePlayoff", "Final");
    }

    [Fact]
    public async Task Matches_AreGroupedByStage()
    {
        var chart = await _service.GetWallChartAsync(default);
        chart.Stages.First(s => s.Stage == "RoundOf32").Matches.Should().HaveCount(2);
        chart.Stages.First(s => s.Stage == "RoundOf16").Matches.Should().HaveCount(1);
    }

    [Fact]
    public async Task SourceDescriptions_AppearWhenTeamsUnknown()
    {
        var chart = await _service.GetWallChartAsync(default);
        var match = chart.Stages.First(s => s.Stage == "RoundOf32").Matches.First(m => m.MatchId == 73);
        match.HomeSourceDescription.Should().Be("Winner Group A");
        match.AwaySourceDescription.Should().Be("Runner-up Group B");
    }

    [Fact]
    public async Task TeamNames_AppearWhenTeamsKnown()
    {
        var chart = await _service.GetWallChartAsync(default);
        var match = chart.Stages.First(s => s.Stage == "RoundOf32").Matches.First(m => m.MatchId == 105);
        match.HomeTeamName.Should().Be("TeamA");
        match.AwayTeamName.Should().Be("TeamB");
    }

    [Fact]
    public async Task WinnerTeamId_IsSetWhenResultAvailable()
    {
        var chart = await _service.GetWallChartAsync(default);
        var match = chart.Stages.First(s => s.Stage == "RoundOf32").Matches.First(m => m.MatchId == 105);
        match.WinnerTeamId.Should().Be(1);
    }

    public void Dispose() => _db.Dispose();
}
