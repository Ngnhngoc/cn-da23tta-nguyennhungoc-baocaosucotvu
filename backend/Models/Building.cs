namespace backend.Models;

public class Building
{
    public int Id { get; set; }
    public int CampusId { get; set; }
    public Campus? Campus { get; set; }

    public string Name { get; set; } = string.Empty; // e.g. "Tòa nhà B1 - Giảng đường"
    public string Code { get; set; } = string.Empty; // e.g. "B1"
    public int TotalFloors { get; set; } = 4;

    public ICollection<Room> Rooms { get; set; } = new List<Room>();
}
