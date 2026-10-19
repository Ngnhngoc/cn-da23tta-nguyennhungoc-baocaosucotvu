namespace backend.Models;

public class Incident
{
    public int Id { get; set; }
    public string IncidentCode { get; set; } = string.Empty; // e.g. "SC-20261005-0001"
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;

    public int RoomId { get; set; }
    public Room? Room { get; set; }

    public string? SpecificLocation { get; set; } // e.g. "Bàn giáo viên", "Góc tường dãy 2"

    public int CategoryId { get; set; }
    public Category? Category { get; set; }

    // Priorities: "Low", "Medium", "High", "Critical"
    public string Priority { get; set; } = "Medium";

    // Statuses: "Pending", "Assigned", "InProgress", "Resolved", "Closed", "Rejected"
    public string Status { get; set; } = "Pending";

    public int ReportedByUserId { get; set; }
    public User? ReportedByUser { get; set; }

    public int? AssignedToUserId { get; set; }
    public User? AssignedToUser { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? AssignedAt { get; set; }
    public DateTime? ResolvedAt { get; set; }
    public DateTime? ClosedAt { get; set; }

    public ICollection<IncidentImage> Images { get; set; } = new List<IncidentImage>();
    public ICollection<IncidentHistory> Histories { get; set; } = new List<IncidentHistory>();
    public IncidentFeedback? Feedback { get; set; }
}
