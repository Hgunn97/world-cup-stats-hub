using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using WorldCupStats.Api.Data;
using WorldCupStats.Api.DTOs;
using WorldCupStats.Api.Entities;
using WorldCupStats.Api.Entities.Enums;
using WorldCupStats.Api.Services;

namespace WorldCupStats.Tests;

public class MatchServiceTests : IDisposable
{
    private readonly AppDbContext _db;
    private readonly MatchService _service;

    public MatchServiceTests()
    {
        var opts = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        _db = new AppDbContext(opts);
        _service = new MatchService(_db);

        _db.Teams.AddRange(
            new Team { Id = 1, Name = "TeamA", CountryCode = "AAA" },
            new Team { Id = 2, Name = "TeamB", CountryCode = "BBB" }
        );
        _db.Matches.Add(new Match
        {
            Id = 1,
            MatchNumber = 1,
            Stage = TournamentStage.GroupStage,
            GroupCode = "A",
            HomeTeamId = 1,
            AwayTeamId = 2,
            Status = MatchStatus.Scheduled,
            KickOffUtc = DateTime.UtcNow
        });
        _db.Matches.Add(new Match
        {
            Id = 2,
            MatchNumber = 73,
            Stage = TournamentStage.RoundOf32,
            HomeTeamId = 1,
            AwayTeamId = 2,
            Status = MatchStatus.Scheduled,
            KickOffUtc = DateTime.UtcNow
        });
        _db.SaveChanges();
    }

    [Fact]
    public async Task UpdateResult_SavesScores()
    {
        var result = await _service.UpdateResultAsync(1, new UpdateMatchResultRequest
        {
            HomeScore = 2, AwayScore = 1, Status = "Finished"
        }, default);

        result!.HomeScore.Should().Be(2);
        result.AwayScore.Should().Be(1);
        result.Status.Should().Be("Finished");
    }

    [Fact]
    public async Task UpdateResult_ReturnsNull_WhenMatchNotFound()
    {
        var result = await _service.UpdateResultAsync(999, new UpdateMatchResultRequest
        {
            HomeScore = 1, AwayScore = 0, Status = "Finished"
        }, default);
        result.Should().BeNull();
    }

    [Fact]
    public async Task UpdateResult_InvalidStatus_ThrowsArgumentException()
    {
        var act = async () => await _service.UpdateResultAsync(1, new UpdateMatchResultRequest
        {
            Status = "NotAStatus"
        }, default);
        await act.Should().ThrowAsync<ArgumentException>();
    }

    [Fact]
    public async Task KnockoutMatch_HomeWin_SetsWinner()
    {
        var result = await _service.UpdateResultAsync(2, new UpdateMatchResultRequest
        {
            HomeScore = 2, AwayScore = 0, Status = "Finished"
        }, default);
        result!.WinnerTeamId.Should().Be(1);
    }

    [Fact]
    public async Task KnockoutMatch_AwayWin_SetsWinner()
    {
        var result = await _service.UpdateResultAsync(2, new UpdateMatchResultRequest
        {
            HomeScore = 0, AwayScore = 1, Status = "Finished"
        }, default);
        result!.WinnerTeamId.Should().Be(2);
    }

    [Fact]
    public async Task KnockoutMatch_Draw_NoAutoWinner()
    {
        var result = await _service.UpdateResultAsync(2, new UpdateMatchResultRequest
        {
            HomeScore = 1, AwayScore = 1, Status = "Finished"
        }, default);
        result!.WinnerTeamId.Should().BeNull();
    }

    [Fact]
    public async Task KnockoutMatch_ManualWinnerOverride_IsRespected()
    {
        var result = await _service.UpdateResultAsync(2, new UpdateMatchResultRequest
        {
            HomeScore = 1, AwayScore = 1, Status = "Finished", WinnerTeamId = 2
        }, default);
        result!.WinnerTeamId.Should().Be(2);
    }

    public void Dispose() => _db.Dispose();
}
