namespace backend.Models;

public class Category
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty; // e.g. "Hệ thống điện & Chiếu sáng", "Máy lạnh & Quạt"
    public string? Icon { get; set; } // e.g. "electrical_services", "ac_unit", "computer", "water_drop"
    public string? Description { get; set; }
}
