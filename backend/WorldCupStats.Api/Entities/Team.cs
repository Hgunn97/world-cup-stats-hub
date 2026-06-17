namespace WorldCupStats.Api.Entities;

public class Team
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string CountryCode { get; set; } = string.Empty;
    public string? GroupCode { get; set; }
    public string? FlagUrl { get; set; }
}
