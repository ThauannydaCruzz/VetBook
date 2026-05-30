using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VetBook.API.Authentication;
using VetBook.CadastroContext.Application.Interfaces;
using VetBook.SharedKernel.Common;

namespace VetBook.API.Controllers;

// Controller responsável pelo login e autenticação dos usuários do sistema.
// Recebe usuario e senha, verifica se são válidos e retorna um token JWT.
// Existem dois tipos de usuários: fixos (admin e veterinario) e donos (autenticados pelo CPF).
[ApiController]
[Route("api/auth")]
[Produces("application/json")]
[Tags("Auth")]
public class AuthController : ControllerBase
{
    // Serviço responsável por gerar tokens JWT
    private readonly JwtTokenService _tokenService;

    // Serviço de donos, usado para verificar CPF e senha no banco de dados
    private readonly IDonoService _donoService;

    // Logger para registrar quem fez login e tentativas inválidas
    private readonly ILogger<AuthController> _logger;

    public AuthController(JwtTokenService tokenService, IDonoService donoService,
                          ILogger<AuthController> logger)
    {
        _tokenService = tokenService;
        _donoService = donoService;
        _logger = logger;
    }

    // Endpoint de login — recebe usuario e senha, retorna um token JWT se válidos.
    // Aceita tanto usuários fixos (admin/veterinario) quanto donos cadastrados no banco.
    [HttpPost("login")]
    [ProducesResponseType(typeof(ApiResponse<LoginResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginRequest request, CancellationToken ct)
    {
        // Passo 1: Verifica se o usuário é um dos fixos (admin ou veterinario)
        // Esses usuários têm credenciais definidas aqui no código, sem banco de dados
        var usuariosFixos = new Dictionary<string, (string Senha, string Role)>
        {
            { "admin",       ("Admin@123!", "Admin") },
            { "veterinario", ("Vet@123!",   "Veterinario") }
        };

        if (usuariosFixos.TryGetValue(request.Usuario.ToLower(), out var credencial)
            && credencial.Senha == request.Senha)
        {
            var token = _tokenService.GerarToken(Guid.NewGuid().ToString(), request.Usuario, credencial.Role);
            _logger.LogInformation("Login fixo: {Usuario} ({Role})", request.Usuario, credencial.Role);
            return Ok(ApiResponse<LoginResponse>.Ok(
                new LoginResponse(token, DateTime.UtcNow.AddHours(1), request.Usuario, credencial.Role),
                "Login realizado com sucesso."));
        }

        // Passo 2: Tenta autenticar como dono — busca pelo CPF e verifica a senha com BCrypt
        var dono = await _donoService.ValidarCredenciaisAsync(request.Usuario, request.Senha, ct);
        if (dono != null)
        {
            var token = _tokenService.GerarToken(dono.Id.ToString(), dono.Nome, "Dono");
            _logger.LogInformation("Login dono: {Nome} ({Id})", dono.Nome, dono.Id);
            return Ok(ApiResponse<LoginResponse>.Ok(
                new LoginResponse(token, DateTime.UtcNow.AddHours(1), dono.Nome, "Dono", dono.Id.ToString()),
                "Login realizado com sucesso."));
        }

        // Se chegou até aqui, as credenciais são inválidas
        _logger.LogWarning("Tentativa de login invalida: {Usuario}", request.Usuario);
        return Unauthorized(ApiResponse.Fail("Usuario ou senha invalidos."));
    }

    // Endpoint que valida o token atual e retorna os dados do usuário autenticado.
    // Usado pelo app para verificar se o token ainda é válido ao abrir o aplicativo.
    // O atributo [Authorize] faz com que o ASP.NET rejeite automaticamente tokens inválidos com 401.
    [HttpGet("me")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status401Unauthorized)]
    public IActionResult Me()
    {
        // Extrai as informações do token JWT que já foi validado pelo middleware
        var userId = User.FindFirstValue(JwtRegisteredClaimNames.Sub)
                  ?? User.FindFirstValue(ClaimTypes.NameIdentifier);
        var nome   = User.FindFirstValue(JwtRegisteredClaimNames.Name)
                  ?? User.FindFirstValue(ClaimTypes.Name);
        var role   = User.FindFirstValue(ClaimTypes.Role);

        return Ok(ApiResponse<object>.Ok(new { userId, nome, role }, "Autenticado."));
    }
}
