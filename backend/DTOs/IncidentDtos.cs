using System.ComponentModel.DataAnnotations;

namespace backend.DTOs;

public class CreateIncidentDto
{
    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [Required]
    public string Description { get; set; } = string.Empty;

    [Required]
    public int RoomId { get; set; }

    [Required]
    public int CategoryId { get; set; }

    // "Low", "Medium", "High", "Critical"
    public string Priority { get; set; } = "Medium";

    public string? SpecificLocation { get; set; }

    public List<string> ImageUrls { get; set; } = new();
}

public class UpdateIncidentStatusDto
{
    // "Assigned", "InProgress", "Resolved", "Closed", "Rejected"
    [Required]
    public string Status { get; set; } = string.Empty;

    public string? ActionNote { get; set; }

    // Optional list of resolution image URLs if status is "Resolved"
    public List<string>? ResolutionImageUrls { get; set; }
}

public class AssignIncidentDto
{
    [Required]
    public int TechnicianId { get; set; }

    public string? Note { get; set; }
}

public class FeedbackDto
{
    [Range(1, 5)]
    public int Rating { get; set; }

    public string? Comment { get; set; }
}

public class IncidentListDto
{
    public int Id { get; set; }
    public string IncidentCode { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Priority { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }

    public int RoomId { get; set; }
    public string RoomNumber { get; set; } = string.Empty;
    public string BuildingName { get; set; } = string.Empty;
    public string CampusName { get; set; } = string.Empty;

    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public string? CategoryIcon { get; set; }

    public string ReportedByFullName { get; set; } = string.Empty;
    public string? AssignedToFullName { get; set; }
    public string? ThumbnailUrl { get; set; }
}

public class IncidentDetailDto
{
    public int Id { get; set; }
    public string IncidentCode { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string? SpecificLocation { get; set; }
    public string Priority { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime? AssignedAt { get; set; }
    public DateTime? ResolvedAt { get; set; }
    public DateTime? ClosedAt { get; set; }

    // Room & Building
    public int RoomId { get; set; }
    public string RoomNumber { get; set; } = string.Empty;
    public string RoomType { get; set; } = string.Empty;
    public string QrCode { get; set; } = string.Empty;
    public string BuildingName { get; set; } = string.Empty;
    public string CampusName { get; set; } = string.Empty;

    // Category
    public int CategoryId { get; set; }
    public string CategoryName { get; set; } = string.Empty;
    public string? CategoryIcon { get; set; }

    // Users
    public UserDto ReportedBy { get; set; } = null!;
    public UserDto? AssignedTo { get; set; }

    // Images
    public List<IncidentImageDto> Images { get; set; } = new();

    // Histories / Timeline
    public List<IncidentHistoryDto> Histories { get; set; } = new();

    // Feedback
    public FeedbackDto? Feedback { get; set; }
}

public class IncidentImageDto
{
    public int Id { get; set; }
    public string ImageUrl { get; set; } = string.Empty;
    public string ImageType { get; set; } = string.Empty; // "Report" or "Resolution"
    public DateTime UploadedAt { get; set; }
}

public class IncidentHistoryDto
{
    public int Id { get; set; }
    public string? PreviousStatus { get; set; }
    public string NewStatus { get; set; } = string.Empty;
    public string ActionNote { get; set; } = string.Empty;
    public string UpdatedByFullName { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}
