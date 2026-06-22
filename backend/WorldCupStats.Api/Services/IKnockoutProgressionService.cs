namespace WorldCupStats.Api.Services;

public interface IKnockoutProgressionService
{
    Task Recalculate();
}