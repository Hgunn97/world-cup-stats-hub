using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using WorldCupStats.Api.Data;
using WorldCupStats.Api.Entities;
using WorldCupStats.Api.Entities.Enums;
using WorldCupStats.Api.Services;

namespace WorldCupStats.Tests;

public class GroupTableServiceTests : IDisposable
{
    private readonly AppDbContext _db;
    private readonly GroupTableService _service;

    public GroupTableServiceTests()
    {
        var opts = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        _db = new AppDbContext(opts);
        _service = new GroupTableService(_db);

        _db.Teams.AddRange(
            new Team { Id = 1, Name = "TeamA", CountryCode = "AAA", GroupCode = "A" },
            new Team { Id = 2, Name = "TeamB", CountryCode = "BBB", GroupCode = "A" },
            new Team { Id = 3, Name = "TeamC", CountryCode = "CCC", GroupCode = "A" },
            new Team { Id = 4, Name = "TeamD", CountryCode = "DDD", GroupCode = "A" }
        );
        _db.SaveChanges();
    }

    private void AddFinishedMatch(int homeId, int awayId, int homeScore, int awayScore)
    {
        _db.Matches.Add(new Match
        {
            MatchNumber = _db.Matches.Count() + 1,
            Stage = TournamentStage.GroupStage,
            GroupCode = "A",
            HomeTeamId = homeId,
            AwayTeamId = awayId,
            HomeScore = homeScore,
            AwayScore = awayScore,
            Status = MatchStatus.Finished,
            KickOffUtc = DateTime.UtcNow
        });
        _db.SaveChanges();
    }

    [Fact]
    public async Task Win_Gives3Points()
    {
        AddFinishedMatch(1, 2, 2, 0);
        var table = await _service.GetGroupTableAsync("A", default);
        table!.Teams.First(t => t.TeamId == 1).Points.Should().Be(3);
        table.Teams.First(t => t.TeamId == 2).Points.Should().Be(0);
    }

    [Fact]
    public async Task Draw_Gives1PointEach()
    {
        AddFinishedMatch(1, 2, 1, 1);
        var table = await _service.GetGroupTableAsync("A", default);
        table!.Teams.First(t => t.TeamId == 1).Points.Should().Be(1);
        table.Teams.First(t => t.TeamId == 2).Points.Should().Be(1);
    }

    [Fact]
    public async Task Loss_Gives0Points()
    {
        AddFinishedMatch(1, 2, 0, 3);
        var table = await _service.GetGroupTableAsync("A", default);
        table!.Teams.First(t => t.TeamId == 1).Points.Should().Be(0);
        table.Teams.First(t => t.TeamId == 2).Points.Should().Be(3);
    }

    [Fact]
    public async Task GoalDifference_IsCalculatedCorrectly()
    {
        AddFinishedMatch(1, 2, 3, 1);
        var table = await _service.GetGroupTableAsync("A", default);
        table!.Teams.First(t => t.TeamId == 1).GoalDifference.Should().Be(2);
        table.Teams.First(t => t.TeamId == 2).GoalDifference.Should().Be(-2);
    }

    [Fact]
    public async Task GoalsForAndAgainst_AreCalculatedCorrectly()
    {
        AddFinishedMatch(1, 2, 3, 1);
        var table = await _service.GetGroupTableAsync("A", default);
        var team1 = table!.Teams.First(t => t.TeamId == 1);
        team1.GoalsFor.Should().Be(3);
        team1.GoalsAgainst.Should().Be(1);
    }

    [Fact]
    public async Task TeamsAreSortedByPointsDescending()
    {
        AddFinishedMatch(1, 2, 2, 0); // TeamA 3pts, TeamB 0pts
        AddFinishedMatch(3, 4, 1, 0); // TeamC 3pts, TeamD 0pts
        AddFinishedMatch(1, 3, 1, 2); // TeamC 3pts more -> 6pts, TeamA 0pts more -> 3pts

        var table = await _service.GetGroupTableAsync("A", default);
        table!.Teams[0].TeamId.Should().Be(3); // TeamC 6pts
        table.Teams[1].TeamId.Should().Be(1); // TeamA 3pts
    }

    [Fact]
    public async Task TeamsWithEqualPoints_SortedByGoalDifference()
    {
        AddFinishedMatch(1, 2, 3, 0); // TeamA 3pts GD+3
        AddFinishedMatch(3, 4, 1, 0); // TeamC 3pts GD+1

        var table = await _service.GetGroupTableAsync("A", default);
        table!.Teams[0].TeamId.Should().Be(1); // Better GD
        table.Teams[1].TeamId.Should().Be(3);
    }

    [Fact]
    public async Task TeamsWithEqualPointsAndGD_SortedByGoalsScored()
    {
        AddFinishedMatch(1, 2, 2, 1); // TeamA 3pts GD+1 GF2
        AddFinishedMatch(3, 4, 3, 2); // TeamC 3pts GD+1 GF3

        var table = await _service.GetGroupTableAsync("A", default);
        table!.Teams[0].TeamId.Should().Be(3); // More goals scored
        table.Teams[1].TeamId.Should().Be(1);
    }

    [Fact]
    public async Task Position_IsAssigned1Based()
    {
        var table = await _service.GetGroupTableAsync("A", default);
        table!.Teams.Select(t => t.Position).Should().BeEquivalentTo([1, 2, 3, 4]);
    }

    public void Dispose() => _db.Dispose();
}
