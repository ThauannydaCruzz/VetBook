using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace VetBook.API.Authentication;

/* Serviço responsável por gerar tokens JWT (JSON Web Token).
 * O token é uma string assinada que contém informações do usuário (claims)
 * e serve como "carteirinha de acesso" para os endpoints protegidos. */
public class JwtTokenService
{
    // Configurações do JWT (chave secreta, issuer, audience, tempo de expiração)
    private readonly JwtSettings _settings;

    public JwtTokenService(JwtSettings settings) => _settings = settings;

    // Gera um token JWT com as informações do usuário.
    // O token contém: ID do usuário, nome, papel (role), ID único do token e data de emissão.
    // Fica válido pelo tempo configurado em JwtSettings.ExpirationMinutes.
    public string GerarToken(string userId, string userName, string role = "User")
    {
        // Cria a chave de assinatura a partir da chave secreta configurada
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_settings.SecretKey));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        // Claims são as informações embutidas no token (o que a API vai saber sobre o usuário)
        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, userId),      // ID do usuário
            new Claim(JwtRegisteredClaimNames.Name, userName),   // Nome do usuário
            new Claim(ClaimTypes.Role, role),                    // Papel: Admin, Veterinario ou Dono
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()), // ID único do token
            new Claim(JwtRegisteredClaimNames.Iat,               // Data de emissão (timestamp Unix)
                DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString(),
                ClaimValueTypes.Integer64)
        };

        // Cria o token com issuer, audience, claims e validade
        var token = new JwtSecurityToken(
            issuer: _settings.Issuer,
            audience: _settings.Audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(_settings.ExpirationMinutes),
            signingCredentials: credentials
        );

        // Serializa o token para a string final (formato: xxxxx.yyyyy.zzzzz)
        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}

// DTO de entrada do login — contém o usuário (CPF ou nome fixo) e a senha
public record LoginRequest(string Usuario, string Senha);

// DTO de resposta do login — contém o token, data de expiração, nome, papel e ID do usuário
public record LoginResponse(string Token, DateTime Expiracao, string Usuario, string Role, string? UserId = null);
