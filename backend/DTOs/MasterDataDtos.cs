namespace backend.DTOs;

public class CampusDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public string Address { get; set; } = string.Empty;
    public List<BuildingDto> Buildings { get; set; } = new();
}

public class BuildingDto
{
    public int Id { get; set; }
    public int CampusId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public int TotalFloors { get; set; }
    public List<RoomDto> Rooms { get; set; } = new();
}

public class RoomDto
{
    public int Id { get; set; }
    public int BuildingId { get; set; }
    public string BuildingName { get; set; } = string.Empty;
    public string CampusName { get; set; } = string.Empty;
    public string RoomNumber { get; set; } = string.Empty;
    public string RoomType { get; set; } = string.Empty;
    public int Floor { get; set; }
    public string QrCode { get; set; } = string.Empty;
    
    // Tiêu chuẩn trang thiết bị phòng học TVU Khu A & Khu B
    public int AirConditionerCount { get; set; } = 2;
    public int FanCount { get; set; } = 2;
    public string FanType { get; set; } = "Quạt trần";
    public int TvCount { get; set; } = 1;
    public int HdmiCount { get; set; } = 1;
    public int BoardCount { get; set; } = 1;
    public int StudentDeskCount { get; set; } = 16;
    public int TeacherDeskCount { get; set; } = 1;

    public string? Description { get; set; }
}

public class CategoryDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Icon { get; set; }
    public string? Description { get; set; }
    public int IncidentCount { get; set; }
}

public class DashboardStatsDto
{
    public int TotalIncidents { get; set; }
    public int PendingCount { get; set; }
    public int InProgressCount { get; set; }
    public int ResolvedCount { get; set; }
    public int ClosedCount { get; set; }
    public int RejectedCount { get; set; }
    public double AverageRating { get; set; }
    public Dictionary<string, int> CategoryStats { get; set; } = new();
    public Dictionary<string, int> BuildingStats { get; set; } = new();
    public List<IncidentListDto> RecentIncidents { get; set; } = new();
}
