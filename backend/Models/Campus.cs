namespace backend.Models;

public class Campus
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty; // e.g. "Khu 1 - Số 126 Nguyễn Thiện Thành"
    public string Code { get; set; } = string.Empty; // e.g. "KHU1"
    public string Address { get; set; } = string.Empty;
    public string? Description { get; set; }

    public ICollection<Building> Buildings { get; set; } = new List<Building>();
}
