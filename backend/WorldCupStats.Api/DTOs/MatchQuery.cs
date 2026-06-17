namespace WorldCupStats.Api.DTOs;

public class MatchQuery
{
    public string? Stage { get; set; }
    public string? GroupCode { get; set; }
    public DateOnly? Date { get; set; }
}
