using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using backend.Data;
using backend.Services;

var builder = WebApplication.CreateBuilder(args);

// 1. Database Connection (MySQL via Pomelo)
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? "Server=127.0.0.1;Port=3306;Database=tvu_facility_db;User=root;Password=;CharSet=utf8mb4;";

builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString));
});

// 2. Custom Services Dependency Injection
builder.Services.AddScoped<ITokenService, TokenService>();
builder.Services.AddScoped<IQrCodeService, QrCodeService>();

// 3. Controllers & JSON Options
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
    });

// 4. JWT Authentication
var jwtKey = builder.Configuration["Jwt:Key"] ?? "TVU_Facility_Incident_Tracking_System_Secret_Key_2026_TrAViNh_UnIvErSiTy";
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "TVU_Facility_Backend";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "TVU_Facility_Clients";

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false;
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
        ValidateIssuer = true,
        ValidIssuer = jwtIssuer,
        ValidateAudience = true,
        ValidAudience = jwtAudience,
        ClockSkew = TimeSpan.Zero
    };
});

builder.Services.AddAuthorization();

// 5. CORS for Flutter Mobile & Web Admin
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// 6. Swagger UI with Bearer Token Auth
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "TVU Facility Incident Reporting API",
        Version = "v1",
        Description = "Hệ thống Báo cáo & Theo dõi Sự cố Cơ sở vật chất - Trường Đại học Trà Vinh (TVU)"
    });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "Nhập token JWT theo định dạng: Bearer {token}",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

var app = builder.Build();

// 7. Auto Migrate / Ensure Database Created & Seeded
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var db = services.GetRequiredService<ApplicationDbContext>();
        db.Database.EnsureCreated();
        Console.WriteLine(">>> [TVU Facility DB] Kết nối MySQL và khởi tạo dữ liệu mẫu Đại học Trà Vinh thành công.");
    }
    catch (Exception ex)
    {
        Console.WriteLine($">>> [TVU Facility DB] Lỗi khởi tạo cơ sở dữ liệu: {ex.Message}");
    }
}

// Ensure wwwroot directory exists
var wwwrootPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
if (!Directory.Exists(wwwrootPath))
{
    Directory.CreateDirectory(wwwrootPath);
}

// 8. Middleware Pipeline
app.UseSwagger(c =>
{
    c.SerializeAsV2 = true;
});
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "TVU Facility Incident API v1");
    c.RoutePrefix = string.Empty; // Serve Swagger at app root URL: http://localhost:5209/
});

app.UseDefaultFiles();
app.UseStaticFiles();

app.UseCors("AllowAll");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
