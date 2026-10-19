using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using backend.Models;

namespace backend.Services;

public interface ITokenService
{
    string GenerateToken(User user);
    DateTime GetExpirationDate();
}

public class TokenService : ITokenService
{
    private readonly IConfiguration _config;

    public TokenService(IConfiguration config)
    {
        _config = config;
    }

    public string GenerateToken(User user)
    {
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_config["Jwt:Key"] ?? "TVU_Facility_Incident_Tracking_System_Secret_Key_2026_TrAViNh_UnIvErSiTy"));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.Name, user.Username),
            new Claim("fullName", user.FullName),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim(ClaimTypes.Role, user.Role),
            new Claim("department", user.DepartmentOrClass ?? "")
        };

        var expirationMinutes = int.TryParse(_config["Jwt:ExpiresInMinutes"], out var mins) ? mins : 10080;
        var expires = DateTime.UtcNow.AddMinutes(expirationMinutes);

        var token = new JwtSecurityToken(
            issuer: _config["Jwt:Issuer"] ?? "TVU_Facility_Backend",
            audience: _config["Jwt:Audience"] ?? "TVU_Facility_Clients",
            claims: claims,
            expires: expires,
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    public DateTime GetExpirationDate()
    {
        var expirationMinutes = int.TryParse(_config["Jwt:ExpiresInMinutes"], out var mins) ? mins : 10080;
        return DateTime.UtcNow.AddMinutes(expirationMinutes);
    }
}
