using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using WorldCupStats.Api.Data;
using WorldCupStats.Api.Entities;
using WorldCupStats.Api.Entities.Enums;
using WorldCupStats.Api.Services;

namespace WorldCupStats.Tests;

public class TeamStatsServiceTests : IDisposable
{
    private readonly AppDbContext _db;
    private readonly TeamStatsService _service;

    public TeamStatsServiceTests()
    {
        var opts = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        _db = new AppDbContext(opts);
        _service = new TeamStatsService(_db);

        _db.Teams.AddRange(
            new Team { Id = 1, Name = "TeamA", CountryCode = "AAA", GroupCode = "A" },
            new Team { Id = 2, Name = "TeamB", CountryCode = "BBB", GroupCode = "A" }
        );
        _db.SaveChanges();
    }

    private void AddMatch(int homeId, int awayId, int homeScore, int awayScore)
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
    public async Task GoalsScored_IsCalculatedCorrectly()
    {
        AddMatch(1, 2, 3, 1);
        var stats = await _service.GetTeamStatsAsync(default);
        stats.First(s => s.TeamId == 1).GoalsScored.Should().Be(3);
        stats.First(s => s.TeamId == 2).GoalsScored.Should().Be(1);
    }

    [Fact]
    public async Task GoalsConceded_IsCalculatedCorrectly()
    {
        AddMatch(1, 2, 3, 1);
        var stats = await _service.GetTeamStatsAsync(default);
        stats.First(s => s.TeamId == 1).GoalsConceded.Should().Be(1);
        stats.First(s => s.TeamId == 2).GoalsConceded.Should().Be(3);
    }

    [Fact]
    public async Task CleanSheet_WhenOpponentScoredZero()
    {
        AddMatch(1, 2, 2, 0);
        var stats = await _service.GetTeamStatsAsync(default);
        stats.First(s => s.TeamId == 1).CleanSheets.Should().Be(1);
        stats.First(s => s.TeamId == 2).CleanSheets.Should().Be(0);
    }

    [Fact]
    public async Task FailedToScore_WhenTeamScoredZero()
    {
        AddMatch(1, 2, 0, 2);
        var stats = await _service.GetTeamStatsAsync(default);
        stats.First(s => s.TeamId == 1).FailedToScore.Should().Be(1);
        stats.First(s => s.TeamId == 2).FailedToScore.Should().Be(0);
    }

    [Fact]
    public async Task GoalsPerMatch_HandlesZeroMatches()
    {
        var stats = await _service.GetTeamStatsAsync(default);
        stats.First(s => s.TeamId == 1).GoalsPerMatch.Should().Be(0);
    }

    [Fact]
    public async Task TopScoringRanking_OrdersByGoalsScoredDesc()
    {
        AddMatch(1, 2, 5, 1);
        var stats = await _service.GetTopScoringTeamsAsync(10, default);
        stats[0].TeamId.Should().Be(1);
        stats[1].TeamId.Should().Be(2);
    }

    [Fact]
    public async Task MostConcededRanking_OrdersByGoalsConcededDesc()
    {
        AddMatch(1, 2, 4, 0);
        var stats = await _service.GetMostConcededTeamsAsync(10, default);
        stats[0].TeamId.Should().Be(2);
        stats[1].TeamId.Should().Be(1);
    }

    [Fact]
    public async Task LimitParameter_CappsResults()
    {
        AddMatch(1, 2, 1, 0);
        var stats = await _service.GetTopScoringTeamsAsync(1, default);
        stats.Count.Should().Be(1);
    }

    public void Dispose() => _db.Dispose();
}
