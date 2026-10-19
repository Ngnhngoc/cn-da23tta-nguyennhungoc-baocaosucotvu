using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UploadsController : ControllerBase
{
    private readonly IWebHostEnvironment _env;

    public UploadsController(IWebHostEnvironment env)
    {
        _env = env;
    }

    [HttpPost]
    [Authorize]
    public async Task<IActionResult> UploadImage(IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest(new { message = "Vui lòng chọn hình ảnh để tải lên." });

        // Validate allowed extensions
        var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".webp", ".heic" };
        var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!allowedExtensions.Contains(ext))
            return BadRequest(new { message = "Định dạng ảnh không hợp lệ (chỉ hỗ trợ JPG, PNG, WEBP)." });

        // Limit size to 10MB
        if (file.Length > 10 * 1024 * 1024)
            return BadRequest(new { message = "Kích thước ảnh không được vượt quá 10MB." });

        var uploadsFolder = Path.Combine(_env.WebRootPath ?? Path.Combine(Directory.GetCurrentDirectory(), "wwwroot"), "uploads", "incidents");
        if (!Directory.Exists(uploadsFolder))
        {
            Directory.CreateDirectory(uploadsFolder);
        }

        var uniqueFileName = $"{Guid.NewGuid():N}{ext}";
        var filePath = Path.Combine(uploadsFolder, uniqueFileName);

        using (var stream = new FileStream(filePath, FileMode.Create))
        {
            await file.CopyToAsync(stream);
        }

        var baseUrl = $"{Request.Scheme}://{Request.Host}";
        var relativeUrl = $"/uploads/incidents/{uniqueFileName}";
        var fullUrl = $"{baseUrl}{relativeUrl}";

        return Ok(new
        {
            fileName = uniqueFileName,
            url = relativeUrl,
            fullUrl = fullUrl
        });
    }
}
