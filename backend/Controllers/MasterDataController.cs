using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using backend.Data;
using backend.DTOs;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class MasterDataController : ControllerBase
{
    private readonly ApplicationDbContext _db;

    public MasterDataController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet("campuses")]
    public async Task<ActionResult<List<CampusDto>>> GetCampuses()
    {
        var campuses = await _db.Campuses
            .Include(c => c.Buildings)
            .ThenInclude(b => b.Rooms.Where(r => r.IsActive))
            .Select(c => new CampusDto
            {
                Id = c.Id,
                Name = c.Name,
                Code = c.Code,
                Address = c.Address,
                Buildings = c.Buildings.Select(b => new BuildingDto
                {
                    Id = b.Id,
                    CampusId = b.CampusId,
                    Name = b.Name,
                    Code = b.Code,
                    TotalFloors = b.TotalFloors,
                    Rooms = b.Rooms.Select(r => new RoomDto
                    {
                        Id = r.Id,
                        BuildingId = r.BuildingId,
                        BuildingName = b.Name,
                        CampusName = c.Name,
                        RoomNumber = r.RoomNumber,
                        RoomType = r.RoomType,
                        Floor = r.Floor,
                        QrCode = r.QrCode,
                        Description = r.Description
                    }).ToList()
                }).ToList()
            })
            .ToListAsync();

        return Ok(campuses);
    }

    [HttpGet("categories")]
    public async Task<ActionResult<List<CategoryDto>>> GetCategories()
    {
        var categories = await _db.Categories
            .Select(c => new CategoryDto
            {
                Id = c.Id,
                Name = c.Name,
                Icon = c.Icon,
                Description = c.Description,
                IncidentCount = _db.Incidents.Count(i => i.CategoryId == c.Id)
            })
            .ToListAsync();

        return Ok(categories);
    }

    [HttpGet("dashboard")]
    public async Task<ActionResult<DashboardStatsDto>> GetDashboardStats()
    {
        var total = await _db.Incidents.CountAsync();
        var pending = await _db.Incidents.CountAsync(i => i.Status == "Pending");
        var inProgress = await _db.Incidents.CountAsync(i => i.Status == "InProgress" || i.Status == "Assigned");
        var resolved = await _db.Incidents.CountAsync(i => i.Status == "Resolved");
        var closed = await _db.Incidents.CountAsync(i => i.Status == "Closed");
        var rejected = await _db.Incidents.CountAsync(i => i.Status == "Rejected");

        var ratings = await _db.IncidentFeedbacks.Select(f => (double)f.Rating).ToListAsync();
        var avgRating = ratings.Count > 0 ? Math.Round(ratings.Average(), 1) : 5.0;

        var categoryStats = await _db.Categories
            .Select(c => new
            {
                c.Name,
                Count = _db.Incidents.Count(i => i.CategoryId == c.Id)
            })
            .ToDictionaryAsync(k => k.Name, v => v.Count);

        var buildingStats = await _db.Buildings
            .Select(b => new
            {
                b.Name,
                Count = _db.Incidents.Count(i => i.Room != null && i.Room.BuildingId == b.Id)
            })
            .ToDictionaryAsync(k => k.Name, v => v.Count);

        var recent = await _db.Incidents
            .Include(i => i.Room).ThenInclude(r => r!.Building).ThenInclude(b => b!.Campus)
            .Include(i => i.Category)
            .Include(i => i.ReportedByUser)
            .Include(i => i.AssignedToUser)
            .Include(i => i.Images)
            .OrderByDescending(i => i.CreatedAt)
            .Take(5)
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

        return Ok(new DashboardStatsDto
        {
            TotalIncidents = total,
            PendingCount = pending,
            InProgressCount = inProgress,
            ResolvedCount = resolved,
            ClosedCount = closed,
            RejectedCount = rejected,
            AverageRating = avgRating,
            CategoryStats = categoryStats,
            BuildingStats = buildingStats,
            RecentIncidents = recent
        });
    }
}
