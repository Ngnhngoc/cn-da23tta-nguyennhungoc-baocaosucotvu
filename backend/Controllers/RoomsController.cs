using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using backend.Data;
using backend.DTOs;
using backend.Models;
using backend.Services;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class RoomsController : ControllerBase
{
    private readonly ApplicationDbContext _db;
    private readonly IQrCodeService _qrCodeService;

    public RoomsController(ApplicationDbContext db, IQrCodeService qrCodeService)
    {
        _db = db;
        _qrCodeService = qrCodeService;
    }

    [HttpGet]
    public async Task<ActionResult<List<RoomDto>>> GetRooms([FromQuery] int? buildingId)
    {
        var query = _db.Rooms
            .Include(r => r.Building)
            .ThenInclude(b => b!.Campus)
            .Where(r => r.IsActive);

        if (buildingId.HasValue)
        {
            query = query.Where(r => r.BuildingId == buildingId.Value);
        }

        var rooms = await query
            .OrderBy(r => r.BuildingId)
            .ThenBy(r => r.Floor)
            .ThenBy(r => r.RoomNumber)
            .Select(r => new RoomDto
            {
                Id = r.Id,
                BuildingId = r.BuildingId,
                BuildingName = r.Building != null ? r.Building.Name : "",
                CampusName = r.Building != null && r.Building.Campus != null ? r.Building.Campus.Name : "",
                RoomNumber = r.RoomNumber,
                RoomType = r.RoomType,
                Floor = r.Floor,
                QrCode = r.QrCode,
                AirConditionerCount = r.AirConditionerCount,
                FanCount = r.FanCount,
                FanType = r.FanType,
                TvCount = r.TvCount,
                HdmiCount = r.HdmiCount,
                BoardCount = r.BoardCount,
                StudentDeskCount = r.StudentDeskCount,
                TeacherDeskCount = r.TeacherDeskCount,
                Description = r.Description
            })
            .ToListAsync();

        return Ok(rooms);
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<RoomDto>> GetRoomById(int id)
    {
        var room = await _db.Rooms
            .Include(r => r.Building)
            .ThenInclude(b => b!.Campus)
            .FirstOrDefaultAsync(r => r.Id == id);

        if (room == null)
            return NotFound(new { message = "Không tìm thấy phòng." });

        return Ok(new RoomDto
        {
            Id = room.Id,
            BuildingId = room.BuildingId,
            BuildingName = room.Building?.Name ?? "",
            CampusName = room.Building?.Campus?.Name ?? "",
            RoomNumber = room.RoomNumber,
            RoomType = room.RoomType,
            Floor = room.Floor,
            QrCode = room.QrCode,
            AirConditionerCount = room.AirConditionerCount,
            FanCount = room.FanCount,
            FanType = room.FanType,
            TvCount = room.TvCount,
            HdmiCount = room.HdmiCount,
            BoardCount = room.BoardCount,
            StudentDeskCount = room.StudentDeskCount,
            TeacherDeskCount = room.TeacherDeskCount,
            Description = room.Description
        });
    }

    // Lookup room by QR Code string or Room Number (e.g. "B31.101", "A42.103", "TVU-B31.101")
    [HttpGet("by-qr/{qrCode}")]
    public async Task<ActionResult<RoomDto>> GetRoomByQrCode(string qrCode)
    {
        var cleanCode = Uri.UnescapeDataString(qrCode).Trim().ToLower();
        var tvuCode = $"tvu-{cleanCode}";
        var strippedCode = cleanCode.StartsWith("tvu-") ? cleanCode.Substring(4) : cleanCode;

        var room = await _db.Rooms
            .Include(r => r.Building)
            .ThenInclude(b => b!.Campus)
            .FirstOrDefaultAsync(r => 
                (r.QrCode.ToLower() == cleanCode || 
                 r.RoomNumber.ToLower() == cleanCode ||
                 r.QrCode.ToLower() == tvuCode ||
                 r.RoomNumber.ToLower() == strippedCode) 
                && r.IsActive);

        if (room == null)
            return NotFound(new { message = $"Không tìm thấy phòng học nào khớp với mã '{qrCode}' tại ĐH Trà Vinh." });

        return Ok(new RoomDto
        {
            Id = room.Id,
            BuildingId = room.BuildingId,
            BuildingName = room.Building?.Name ?? "",
            CampusName = room.Building?.Campus?.Name ?? "",
            RoomNumber = room.RoomNumber,
            RoomType = room.RoomType,
            Floor = room.Floor,
            QrCode = room.QrCode,
            AirConditionerCount = room.AirConditionerCount,
            FanCount = room.FanCount,
            FanType = room.FanType,
            TvCount = room.TvCount,
            HdmiCount = room.HdmiCount,
            BoardCount = room.BoardCount,
            StudentDeskCount = room.StudentDeskCount,
            TeacherDeskCount = room.TeacherDeskCount,
            Description = room.Description
        });
    }

    // Download/View generated QR Code PNG image for room sticker printing
    [HttpGet("{id:int}/qr-code-image")]
    public async Task<IActionResult> GetRoomQrCodeImage(int id, [FromQuery] int size = 10)
    {
        var room = await _db.Rooms.FindAsync(id);
        if (room == null)
            return NotFound(new { message = "Không tìm thấy phòng." });

        var imageBytes = _qrCodeService.GenerateQrCodePng(room.QrCode, size);
        return File(imageBytes, "image/png", $"TVU_QR_{room.RoomNumber}.png");
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<RoomDto>> CreateRoom([FromBody] RoomDto dto)
    {
        var existing = await _db.Rooms.AnyAsync(r => r.QrCode.ToLower() == dto.QrCode.ToLower());
        if (existing)
            return BadRequest(new { message = "Mã định danh QR đã tồn tại." });

        var room = new Room
        {
            BuildingId = dto.BuildingId,
            RoomNumber = dto.RoomNumber.Trim(),
            RoomType = dto.RoomType,
            Floor = dto.Floor,
            QrCode = string.IsNullOrWhiteSpace(dto.QrCode) ? $"TVU-{dto.RoomNumber.Trim()}" : dto.QrCode.Trim(),
            AirConditionerCount = dto.AirConditionerCount,
            FanCount = dto.FanCount,
            FanType = string.IsNullOrWhiteSpace(dto.FanType) ? "Quạt trần" : dto.FanType,
            TvCount = dto.TvCount,
            HdmiCount = dto.HdmiCount,
            BoardCount = dto.BoardCount,
            StudentDeskCount = dto.StudentDeskCount,
            TeacherDeskCount = dto.TeacherDeskCount,
            Description = dto.Description,
            IsActive = true
        };

        _db.Rooms.Add(room);
        await _db.SaveChangesAsync();

        dto.Id = room.Id;
        return CreatedAtAction(nameof(GetRoomById), new { id = room.Id }, dto);
    }
}
