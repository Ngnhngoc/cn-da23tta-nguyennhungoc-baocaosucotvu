namespace backend.Models;

public class IncidentHistory
{
    public int Id { get; set; }
    public int IncidentId { get; set; }
    public Incident? Incident { get; set; }

    public int UserId { get; set; }
    public User? User { get; set; }

    public string? PreviousStatus { get; set; }
    public string NewStatus { get; set; } = string.Empty;
    public string ActionNote { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
