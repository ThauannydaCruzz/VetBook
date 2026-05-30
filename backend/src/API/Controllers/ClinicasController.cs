using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VetBook.SharedKernel.Common;
using VetBook.VeterinarioContext.Application.DTOs;
using VetBook.VeterinarioContext.Application.UseCases;

namespace VetBook.API.Controllers;

// Controller responsável pelo gerenciamento de clínicas veterinárias.
// Clínicas podem ser associadas a veterinários.
// Operações de escrita (criar, atualizar, remover) são restritas ao perfil Admin.
[ApiController]
[Route("api/clinicas")]
[Produces("application/json")]
[Tags("Clinicas")]
public class ClinicasController : ControllerBase
{
    // Use Cases responsáveis por cada operação de clínica (padrão DDD)
    private readonly CriarClinicaUseCase     _criar;
    private readonly ListarClinicasUseCase   _listar;
    private readonly ListarClinicasAtivasUseCase _listarAtivas;
    private readonly AtualizarClinicaUseCase _atualizar;
    private readonly RemoverClinicaUseCase   _remover;

    public ClinicasController(
        CriarClinicaUseCase criar,
        ListarClinicasUseCase listar,
        ListarClinicasAtivasUseCase listarAtivas,
        AtualizarClinicaUseCase atualizar,
        RemoverClinicaUseCase remover)
    {
        _criar   = criar;
        _listar  = listar;
        _listarAtivas = listarAtivas;
        _atualizar = atualizar;
        _remover = remover;
    }

    // Lista apenas as clínicas ativas — usada no agendamento e na seleção de clínica no app.
    // Qualquer usuário autenticado pode acessar.
    [HttpGet("ativas")]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<List<ClinicaResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> ListarAtivas(CancellationToken ct)
    {
        var result = await _listarAtivas.ExecutarAsync(ct);
        return Ok(ApiResponse<List<ClinicaResponse>>.Ok(result, "Clinicas ativas listadas."));
    }

    // Lista todas as clínicas com paginação — usado pelo painel admin.
    // Restrito ao perfil Admin.
    [HttpGet]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(typeof(ApiResponse<PagedResult<ClinicaResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> Listar(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        [FromQuery] string? busca = null,
        CancellationToken ct = default)
    {
        var result = await _listar.ExecutarAsync(page, pageSize, busca, ct);
        return Ok(ApiResponse<PagedResult<ClinicaResponse>>.Ok(result, "Clinicas listadas."));
    }

    // Cadastra uma nova clínica no sistema.
    // Restrito ao perfil Admin.
    [HttpPost]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(typeof(ApiResponse<ClinicaResponse>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Criar([FromBody] CreateClinicaRequest request, CancellationToken ct)
    {
        var result = await _criar.ExecutarAsync(request, ct);
        return CreatedAtAction(nameof(Listar), new { id = result.Id },
            ApiResponse<ClinicaResponse>.Ok(result, "Clinica cadastrada com sucesso."));
    }

    // Atualiza os dados de uma clínica existente (nome, endereço, telefone, etc.).
    // Restrito ao perfil Admin.
    [HttpPut("{id:guid}")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(typeof(ApiResponse<ClinicaResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Atualizar(Guid id, [FromBody] UpdateClinicaRequest request, CancellationToken ct)
    {
        var result = await _atualizar.ExecutarAsync(id, request, ct);
        return Ok(ApiResponse<ClinicaResponse>.Ok(result, "Clinica atualizada com sucesso."));
    }

    // Remove uma clínica do sistema pelo ID.
    // Restrito ao perfil Admin.
    [HttpDelete("{id:guid}")]
    [Authorize(Roles = "Admin")]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Remover(Guid id, CancellationToken ct)
    {
        await _remover.ExecutarAsync(id, ct);
        return Ok(ApiResponse.Ok("Clinica removida com sucesso."));
    }
}
