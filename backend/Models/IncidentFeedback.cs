namespace backend.Models;

public class IncidentFeedback
{
    public int Id { get; set; }
    public int IncidentId { get; set; }
    public Incident? Incident { get; set; }

    public int UserId { get; set; }
    public User? User { get; set; }

    public int Rating { get; set; } // 1 - 5 stars
    public string? Comment { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
