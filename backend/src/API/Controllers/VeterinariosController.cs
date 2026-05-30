using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VetBook.SharedKernel.Common;
using VetBook.VeterinarioContext.Application.DTOs;
using VetBook.VeterinarioContext.Application.Interfaces;
using VetBook.VeterinarioContext.Domain.Interfaces;

namespace VetBook.API.Controllers;

// Controller responsável pelo gerenciamento de veterinários do sistema.
// Permite listar, cadastrar, atualizar, ativar/inativar e remover veterinários.
// Operações de escrita exigem perfil Admin ou Veterinario.
[ApiController]
[Route("api/veterinarios")]
[Authorize]
[Produces("application/json")]
[Tags("Veterinarios")]
public class VeterinariosController : ControllerBase
{
    // Serviço de veterinários — centraliza a lógica de negócio
    private readonly IVeterinarioService _service;

    // Logger para registrar criação e remoção de veterinários
    private readonly ILogger<VeterinariosController> _logger;

    public VeterinariosController(IVeterinarioService service, ILogger<VeterinariosController> logger)
    {
        _service = service;
        _logger  = logger;
    }

    // Lista todos os veterinários com paginação e filtros (nome, CRMV, especialidade, ativo).
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<PagedResult<VeterinarioResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> Listar([FromQuery] VeterinarioFiltro filtro, CancellationToken ct)
    {
        var result = await _service.ListarAsync(filtro, ct);
        return Ok(ApiResponse<PagedResult<VeterinarioResponse>>.Ok(result, "Operacao realizada com sucesso."));
    }

    // Lista apenas os veterinários ativos — usado no agendamento de consultas.
    // O app mostra apenas veterinários disponíveis para o dono escolher.
    [HttpGet("ativos")]
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<VeterinarioResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> ListarAtivos(CancellationToken ct)
    {
        var result = await _service.ListarAtivosAsync(ct);
        return Ok(ApiResponse<IEnumerable<VeterinarioResponse>>.Ok(result, "Operacao realizada com sucesso."));
    }

    // Busca um veterinário específico pelo ID.
    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(ApiResponse<VeterinarioResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ObterPorId(Guid id, CancellationToken ct)
    {
        var result = await _service.ObterPorIdAsync(id, ct);
        return Ok(ApiResponse<VeterinarioResponse>.Ok(result, "Operacao realizada com sucesso."));
    }

    // Cadastra um novo veterinário no sistema.
    // Restrito a perfis Admin e Veterinario — donos não podem criar veterinários.
    [HttpPost]
    [Authorize(Roles = "Admin,Veterinario")]
    [ProducesResponseType(typeof(ApiResponse<VeterinarioResponse>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Criar([FromBody] CreateVeterinarioRequest request, CancellationToken ct)
    {
        var result = await _service.CriarAsync(request, ct);
        _logger.LogInformation("Veterinario criado: {Id} - {Nome}", result.Id, result.Nome);
        return CreatedAtAction(nameof(ObterPorId), new { id = result.Id },
            ApiResponse<VeterinarioResponse>.Ok(result, "Veterinario cadastrado com sucesso."));
    }

    // Atualiza dados do veterinário (nome, especialidade, email, telefone, clínica).
    // Restrito a perfis Admin e Veterinario.
    [HttpPut("{id:guid}")]
    [Authorize(Roles = "Admin,Veterinario")]
    [ProducesResponseType(typeof(ApiResponse<VeterinarioResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Atualizar(Guid id, [FromBody] UpdateVeterinarioRequest request, CancellationToken ct)
    {
        var result = await _service.AtualizarAsync(id, request, ct);
        return Ok(ApiResponse<VeterinarioResponse>.Ok(result, "Veterinario atualizado com sucesso."));
    }

    // Ativa um veterinário que estava inativo — ele volta a aparecer para agendamentos.
    [HttpPatch("{id:guid}/ativar")]
    [Authorize(Roles = "Admin,Veterinario")]
    [ProducesResponseType(typeof(ApiResponse<VeterinarioResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Ativar(Guid id, CancellationToken ct)
    {
        await _service.AtivarAsync(id, ct);
        var result = await _service.ObterPorIdAsync(id, ct);
        return Ok(ApiResponse<VeterinarioResponse>.Ok(result, "Veterinario ativado com sucesso."));
    }

    // Inativa um veterinário — ele deixa de aparecer na lista de agendamentos.
    [HttpPatch("{id:guid}/inativar")]
    [Authorize(Roles = "Admin,Veterinario")]
    [ProducesResponseType(typeof(ApiResponse<VeterinarioResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Inativar(Guid id, CancellationToken ct)
    {
        await _service.InativarAsync(id, ct);
        var result = await _service.ObterPorIdAsync(id, ct);
        return Ok(ApiResponse<VeterinarioResponse>.Ok(result, "Veterinario inativado com sucesso."));
    }

    // Remove definitivamente um veterinário do sistema.
    // Restrito a perfis Admin e Veterinario.
    [HttpDelete("{id:guid}")]
    [Authorize(Roles = "Admin,Veterinario")]
    [ProducesResponseType(StatusCodes.Status204NoContent)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Remover(Guid id, CancellationToken ct)
    {
        await _service.RemoverAsync(id, ct);
        _logger.LogInformation("Veterinario removido: {Id}", id);
        return NoContent();
    }
}
