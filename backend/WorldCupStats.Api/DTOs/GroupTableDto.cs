namespace WorldCupStats.Api.DTOs;

public class GroupTableDto
{
    public string GroupCode { get; set; } = string.Empty;
    public List<GroupTableRowDto> Teams { get; set; } = [];
}
