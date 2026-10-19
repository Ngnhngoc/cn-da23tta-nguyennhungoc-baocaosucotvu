using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using backend.Data;
using backend.DTOs;
using backend.Models;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class IncidentsController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public IncidentsController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    public async Task<ActionResult<List<IncidentListDto>>> GetIncidents(
        [FromQuery] string? status,
        [FromQuery] int? categoryId,
        [FromQuery] int? buildingId,
        [FromQuery] string? priority,
        [FromQuery] string? search)
    {
        var query = _db.Incidents
            .Include(i => i.Room).ThenInclude(r => r!.Building).ThenInclude(b => b!.Campus)
            .Include(i => i.Category)
            .Include(i => i.ReportedByUser)
            .Include(i => i.AssignedToUser)
            .Include(i => i.Images)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(status))
            query = query.Where(i => i.Status.ToLower() == status.ToLower());

        if (categoryId.HasValue)
            query = query.Where(i => i.CategoryId == categoryId.Value);

        if (buildingId.HasValue)
            query = query.Where(i => i.Room != null && i.Room.BuildingId == buildingId.Value);

        if (!string.IsNullOrWhiteSpace(priority))
            query = query.Where(i => i.Priority.ToLower() == priority.ToLower());

        if (!string.IsNullOrWhiteSpace(search))
        {
            var s = search.ToLower();
            query = query.Where(i => 
                i.Title.ToLower().Contains(s) || 
                i.IncidentCode.ToLower().Contains(s) || 
                (i.Room != null && i.Room.RoomNumber.ToLower().Contains(s)));
        }

        var incidents = await query
            .OrderByDescending(i => i.CreatedAt)
            .Select(i => new IncidentListDto
            {
                Id = i.Id,
                IncidentCode = i.IncidentCode,
                Title = i.Title,
                Description = i.Description,
                Priority = i.Priority,
                Status = i.Status,
                CreatedAt = i.CreatedAt,
                RoomId = i.RoomId,
                RoomNumber = i.Room != null ? i.Room.RoomNumber : "",
                BuildingName = i.Room != null && i.Room.Building != null ? i.Room.Building.Name : "",
                CampusName = i.Room != null && i.Room.Building != null && i.Room.Building.Campus != null ? i.Room.Building.Campus.Name : "",
                CategoryId = i.CategoryId,
                CategoryName = i.Category != null ? i.Category.Name : "",
                CategoryIcon = i.Category != null ? i.Category.Icon : "",
                ReportedByFullName = i.ReportedByUser != null ? i.ReportedByUser.FullName : "",
                AssignedToFullName = i.AssignedToUser != null ? i.AssignedToUser.FullName : null,
                ThumbnailUrl = i.Images.Select(img => img.ImageUrl).FirstOrDefault()
            })
            .ToListAsync();

        return Ok(incidents);
    }

    [HttpGet("{id:int}")]
    public async Task<ActionResult<IncidentDetailDto>> GetIncidentById(int id)
    {
        var i = await _db.Incidents
            .Include(x => x.Room).ThenInclude(r => r!.Building).ThenInclude(b => b!.Campus)
            .Include(x => x.Category)
            .Include(x => x.ReportedByUser)
            .Include(x => x.AssignedToUser)
            .Include(x => x.Images)
            .Include(x => x.Histories).ThenInclude(h => h.User)
            .Include(x => x.Feedback)
            .FirstOrDefaultAsync(x => x.Id == id);

        if (i == null)
            return NotFound(new { message = "Không tìm thấy thông tin sự cố." });

        return Ok(new IncidentDetailDto
        {
            Id = i.Id,
            IncidentCode = i.IncidentCode,
            Title = i.Title,
            Description = i.Description,
            SpecificLocation = i.SpecificLocation,
            Priority = i.Priority,
            Status = i.Status,
            CreatedAt = i.CreatedAt,
            AssignedAt = i.AssignedAt,
            ResolvedAt = i.ResolvedAt,
            ClosedAt = i.ClosedAt,
            RoomId = i.RoomId,
            RoomNumber = i.Room?.RoomNumber ?? "",
            RoomType = i.Room?.RoomType ?? "",
            QrCode = i.Room?.QrCode ?? "",
            BuildingName = i.Room?.Building?.Name ?? "",
            CampusName = i.Room?.Building?.Campus?.Name ?? "",
            CategoryId = i.CategoryId,
            CategoryName = i.Category?.Name ?? "",
            CategoryIcon = i.Category?.Icon,
            ReportedBy = new UserDto
            {
                Id = i.ReportedByUser!.Id,
                Username = i.ReportedByUser.Username,
                FullName = i.ReportedByUser.FullName,
                Email = i.ReportedByUser.Email,
                PhoneNumber = i.ReportedByUser.PhoneNumber,
                Role = i.ReportedByUser.Role,
                DepartmentOrClass = i.ReportedByUser.DepartmentOrClass
            },
            AssignedTo = i.AssignedToUser == null ? null : new UserDto
            {
                Id = i.AssignedToUser.Id,
                Username = i.AssignedToUser.Username,
                FullName = i.AssignedToUser.FullName,
                Email = i.AssignedToUser.Email,
                PhoneNumber = i.AssignedToUser.PhoneNumber,
                Role = i.AssignedToUser.Role,
                DepartmentOrClass = i.AssignedToUser.DepartmentOrClass
            },
            Images = i.Images.OrderBy(img => img.UploadedAt).Select(img => new IncidentImageDto
            {
                Id = img.Id,
                ImageUrl = img.ImageUrl,
                ImageType = img.ImageType,
                UploadedAt = img.UploadedAt
            }).ToList(),
            Histories = i.Histories.OrderByDescending(h => h.CreatedAt).Select(h => new IncidentHistoryDto
            {
                Id = h.Id,
                PreviousStatus = h.PreviousStatus,
                NewStatus = h.NewStatus,
                ActionNote = h.ActionNote,
                UpdatedByFullName = h.User?.FullName ?? "Hệ thống",
                CreatedAt = h.CreatedAt
            }).ToList(),
            Feedback = i.Feedback == null ? null : new FeedbackDto
            {
                Rating = i.Feedback.Rating,
                Comment = i.Feedback.Comment
            }
        });
    }

    [HttpPost]
    [Authorize]
    public async Task<ActionResult<IncidentDetailDto>> CreateIncident([FromBody] CreateIncidentDto dto)
    {
        var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(userIdStr, out var userId))
            return Unauthorized();

        var room = await _db.Rooms.FindAsync(dto.RoomId);
        if (room == null)
            return BadRequest(new { message = "Phòng học không tồn tại." });

        var category = await _db.Categories.FindAsync(dto.CategoryId);
        if (category == null)
            return BadRequest(new { message = "Loại sự cố không hợp lệ." });

        // Generate Incident Code: SC-YYYYMMDD-XXXX
        var dateStr = DateTime.UtcNow.ToString("yyyyMMdd");
        var countToday = await _db.Incidents.CountAsync(x => x.CreatedAt.Date == DateTime.UtcNow.Date);
        var incidentCode = $"SC-{dateStr}-{(countToday + 1):D4}";

        var incident = new Incident
        {
            IncidentCode = incidentCode,
            Title = dto.Title.Trim(),
            Description = dto.Description.Trim(),
            RoomId = dto.RoomId,
            CategoryId = dto.CategoryId,
            Priority = string.IsNullOrWhiteSpace(dto.Priority) ? "Medium" : dto.Priority,
            SpecificLocation = dto.SpecificLocation?.Trim(),
            Status = "Pending",
            ReportedByUserId = userId,
            CreatedAt = DateTime.UtcNow
        };

        // Attach initial report images
        if (dto.ImageUrls != null && dto.ImageUrls.Count > 0)
        {
            foreach (var imgUrl in dto.ImageUrls)
            {
                incident.Images.Add(new IncidentImage
                {
                    ImageUrl = imgUrl,
                    ImageType = "Report",
                    UploadedAt = DateTime.UtcNow,
                    UploadedByUserId = userId
                });
            }
        }

        // Add first history record
        incident.Histories.Add(new IncidentHistory
        {
            UserId = userId,
            PreviousStatus = null,
            NewStatus = "Pending",
            ActionNote = "Sự cố đã được tạo và gửi đến Phòng Quản trị CSVC TVU để tiếp nhận.",
            CreatedAt = DateTime.UtcNow
        });

        _db.Incidents.Add(incident);
        await _db.SaveChangesAsync();

        return CreatedAtAction(nameof(GetIncidentById), new { id = incident.Id }, new { id = incident.Id, incidentCode = incident.IncidentCode });
    }

    [HttpPut("{id:int}/assign")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> AssignIncident(int id, [FromBody] AssignIncidentDto dto)
    {
        var currentUserIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        int.TryParse(currentUserIdStr, out var currentUserId);

        var incident = await _db.Incidents.FindAsync(id);
        if (incident == null)
            return NotFound(new { message = "Không tìm thấy sự cố." });

        var technician = await _db.Users.FindAsync(dto.TechnicianId);
        if (technician == null || technician.Role != "Technician")
            return BadRequest(new { message = "Kỹ thuật viên được chọn không hợp lệ." });

        var prevStatus = incident.Status;
        incident.AssignedToUserId = technician.Id;
        incident.AssignedAt = DateTime.UtcNow;
        incident.Status = "Assigned";

        var note = string.IsNullOrWhiteSpace(dto.Note) 
            ? $"Phân công cho kỹ thuật viên {technician.FullName} xử lý."
            : $"Phân công cho {technician.FullName}. Ghi chú: {dto.Note}";

        _db.IncidentHistories.Add(new IncidentHistory
        {
            IncidentId = incident.Id,
            UserId = currentUserId,
            PreviousStatus = prevStatus,
            NewStatus = "Assigned",
            ActionNote = note,
            CreatedAt = DateTime.UtcNow
        });

        // Add Notification for technician
        _db.Notifications.Add(new Notification
        {
            UserId = technician.Id,
            IncidentId = incident.Id,
            Title = "Nhiệm vụ sửa chữa mới",
            Message = $"Bạn vừa được phân công xử lý sự cố: {incident.Title} tại phòng {incident.RoomId}.",
            CreatedAt = DateTime.UtcNow
        });

        await _db.SaveChangesAsync();
        return Ok(new { message = "Đã phân công kỹ thuật viên thành công.", status = incident.Status });
    }

    [HttpPut("{id:int}/status")]
    [Authorize]
    public async Task<IActionResult> UpdateIncidentStatus(int id, [FromBody] UpdateIncidentStatusDto dto)
    {
        var currentUserIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        int.TryParse(currentUserIdStr, out var currentUserId);

        var incident = await _db.Incidents
            .Include(i => i.ReportedByUser)
            .FirstOrDefaultAsync(i => i.Id == id);

        if (incident == null)
            return NotFound(new { message = "Không tìm thấy sự cố." });

        var prevStatus = incident.Status;
        incident.Status = dto.Status;

        if (dto.Status == "Resolved")
        {
            incident.ResolvedAt = DateTime.UtcNow;
        }
        else if (dto.Status == "Closed")
        {
            incident.ClosedAt = DateTime.UtcNow;
        }

        // Attach resolution images if provided
        if (dto.ResolutionImageUrls != null && dto.ResolutionImageUrls.Count > 0)
        {
            foreach (var imgUrl in dto.ResolutionImageUrls)
            {
                _db.IncidentImages.Add(new IncidentImage
                {
                    IncidentId = incident.Id,
                    ImageUrl = imgUrl,
                    ImageType = "Resolution",
                    UploadedAt = DateTime.UtcNow,
                    UploadedByUserId = currentUserId
                });
            }
        }

        var note = dto.ActionNote ?? $"Trạng thái sự cố chuyển sang: {dto.Status}";

        _db.IncidentHistories.Add(new IncidentHistory
        {
            IncidentId = incident.Id,
            UserId = currentUserId,
            PreviousStatus = prevStatus,
            NewStatus = dto.Status,
            ActionNote = note,
            CreatedAt = DateTime.UtcNow
        });

        // Notify reporter about progress
        _db.Notifications.Add(new Notification
        {
            UserId = incident.ReportedByUserId,
            IncidentId = incident.Id,
            Title = $"Cập nhật sự cố: {incident.Title}",
            Message = $"Trạng thái đã chuyển sang [{dto.Status}]: {note}",
            CreatedAt = DateTime.UtcNow
        });

        await _db.SaveChangesAsync();
        return Ok(new { message = "Đã cập nhật trạng thái sự cố.", status = incident.Status });
    }

    [HttpPost("{id:int}/feedback")]
    [Authorize]
    public async Task<IActionResult> SubmitFeedback(int id, [FromBody] FeedbackDto dto)
    {
        var currentUserIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        int.TryParse(currentUserIdStr, out var currentUserId);

        var incident = await _db.Incidents
            .Include(i => i.Feedback)
            .FirstOrDefaultAsync(i => i.Id == id);

        if (incident == null)
            return NotFound(new { message = "Không tìm thấy sự cố." });

        if (incident.Feedback != null)
            return BadRequest(new { message = "Sự cố này đã được đánh giá trước đó." });

        var feedback = new IncidentFeedback
        {
            IncidentId = incident.Id,
            UserId = currentUserId,
            Rating = dto.Rating,
            Comment = dto.Comment?.Trim(),
            CreatedAt = DateTime.UtcNow
        };

        _db.IncidentFeedbacks.Add(feedback);
        incident.Status = "Closed";
        incident.ClosedAt = DateTime.UtcNow;

        _db.IncidentHistories.Add(new IncidentHistory
        {
            IncidentId = incident.Id,
            UserId = currentUserId,
            PreviousStatus = "Resolved",
            NewStatus = "Closed",
            ActionNote = $"Người báo cáo đánh giá {dto.Rating}/5 sao và nghiệm thu đóng sự cố.",
            CreatedAt = DateTime.UtcNow
        });

        await _db.SaveChangesAsync();
        return Ok(new { message = "Cảm ơn bạn đã gửi đánh giá chất lượng phục vụ!", feedbackId = feedback.Id });
    }

    [HttpGet("my-reports")]
    [Authorize]
    public async Task<ActionResult<List<IncidentListDto>>> GetMyReports()
    {
        var currentUserIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(currentUserIdStr, out var currentUserId))
            return Unauthorized();

        var list = await _db.Incidents
            .Include(i => i.Room).ThenInclude(r => r!.Building).ThenInclude(b => b!.Campus)
            .Include(i => i.Category)
            .Include(i => i.ReportedByUser)
            .Include(i => i.AssignedToUser)
            .Include(i => i.Images)
            .Where(i => i.ReportedByUserId == currentUserId)
            .OrderByDescending(i => i.CreatedAt)
            .Select(i => new IncidentListDto
            {
                Id = i.Id,
                IncidentCode = i.IncidentCode,
                Title = i.Title,
                Description = i.Description,
                Priority = i.Priority,
                Status = i.Status,
                CreatedAt = i.CreatedAt,
                RoomId = i.RoomId,
                RoomNumber = i.Room != null ? i.Room.RoomNumber : "",
                BuildingName = i.Room != null && i.Room.Building != null ? i.Room.Building.Name : "",
                CampusName = i.Room != null && i.Room.Building != null && i.Room.Building.Campus != null ? i.Room.Building.Campus.Name : "",
                CategoryId = i.CategoryId,
                CategoryName = i.Category != null ? i.Category.Name : "",
                CategoryIcon = i.Category != null ? i.Category.Icon : "",
                ReportedByFullName = i.ReportedByUser != null ? i.ReportedByUser.FullName : "",
                AssignedToFullName = i.AssignedToUser != null ? i.AssignedToUser.FullName : null,
                ThumbnailUrl = i.Images.Select(img => img.ImageUrl).FirstOrDefault()
            })
            .ToListAsync();

        return Ok(list);
    }

    [HttpGet("assigned-to-me")]
    [Authorize]
    public async Task<ActionResult<List<IncidentListDto>>> GetAssignedToMe()
    {
        var currentUserIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!int.TryParse(currentUserIdStr, out var currentUserId))
            return Unauthorized();

        var list = await _db.Incidents
            .Include(i => i.Room).ThenInclude(r => r!.Building).ThenInclude(b => b!.Campus)
            .Include(i => i.Category)
            .Include(i => i.ReportedByUser)
            .Include(i => i.AssignedToUser)
            .Include(i => i.Images)
            .Where(i => i.AssignedToUserId == currentUserId)
            .OrderByDescending(i => i.CreatedAt)
            .Select(i => new IncidentListDto
            {
                Id = i.Id,
                IncidentCode = i.IncidentCode,
                Title = i.Title,
                Description = i.Description,
                Priority = i.Priority,
                Status = i.Status,
                CreatedAt = i.CreatedAt,
                RoomId = i.RoomId,
                RoomNumber = i.Room != null ? i.Room.RoomNumber : "",
                BuildingName = i.Room != null && i.Room.Building != null ? i.Room.Building.Name : "",
                CampusName = i.Room != null && i.Room.Building != null && i.Room.Building.Campus != null ? i.Room.Building.Campus.Name : "",
                CategoryId = i.CategoryId,
                CategoryName = i.Category != null ? i.Category.Name : "",
                CategoryIcon = i.Category != null ? i.Category.Icon : "",
                ReportedByFullName = i.ReportedByUser != null ? i.ReportedByUser.FullName : "",
                AssignedToFullName = i.AssignedToUser != null ? i.AssignedToUser.FullName : null,
                ThumbnailUrl = i.Images.Select(img => img.ImageUrl).FirstOrDefault()
            })
            .ToListAsync();

        return Ok(list);
    }
}
