namespace backend.Models;

public class Room
{
    public int Id { get; set; }
    public int BuildingId { get; set; }
    public Building? Building { get; set; }

    public string RoomNumber { get; set; } = string.Empty; // e.g. "B31.101"
    public string RoomType { get; set; } = "LectureHall"; // LectureHall, ComputerLab, Office, Restroom, Workshop
    public int Floor { get; set; } = 1;
    public string QrCode { get; set; } = string.Empty; // e.g. "TVU-B31.101"

    // Tiêu chuẩn trang bị phòng học Khu A & Khu B theo yêu cầu hiện trạng TVU
    public int AirConditionerCount { get; set; } = 2; // 2 máy lạnh
    public int FanCount { get; set; } = 2; // 2 quạt trần hoặc 4 quạt điện
    public string FanType { get; set; } = "Quạt trần"; // Quạt trần / Quạt điện
    public int TvCount { get; set; } = 1; // 1 Tivi trình chiếu
    public int HdmiCount { get; set; } = 1; // 1 Cổng HDMI bàn giáo viên
    public int BoardCount { get; set; } = 1; // 1 Bảng mica trắng
    public int StudentDeskCount { get; set; } = 16; // 14-18 bàn học sinh viên
    public int TeacherDeskCount { get; set; } = 1; // 1 bàn giáo viên

    public string? Description { get; set; }
    public bool IsActive { get; set; } = true;
}
