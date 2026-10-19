namespace backend.Models;

public class IncidentImage
{
    public int Id { get; set; }
    public int IncidentId { get; set; }
    public Incident? Incident { get; set; }

    public string ImageUrl { get; set; } = string.Empty;
    // "Report" (ảnh sự cố lúc báo) or "Resolution" (ảnh sau khi sửa xong)
    public string ImageType { get; set; } = "Report";
    public DateTime UploadedAt { get; set; } = DateTime.UtcNow;
    public int UploadedByUserId { get; set; }
}
