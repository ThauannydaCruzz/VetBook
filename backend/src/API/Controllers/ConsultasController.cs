using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using VetBook.AgendamentoContext.Application.DTOs;
using VetBook.AgendamentoContext.Application.Interfaces;
using VetBook.AgendamentoContext.Domain.Interfaces;
using VetBook.SharedKernel.Common;

namespace VetBook.API.Controllers;

// Controller responsável pelo agendamento e gerenciamento de consultas veterinárias.
// Cobre todo o ciclo de vida de uma consulta: Agendada → Confirmada → Finalizada (ou Cancelada).
// Todos os endpoints exigem autenticação com token JWT.
[ApiController]
[Route("api/consultas")]
[Authorize]
[Produces("application/json")]
[Tags("Consultas")]
public class ConsultasController : ControllerBase
{
    // Serviço de consultas — contém toda a lógica de negócio do agendamento
    private readonly IConsultaService _service;

    // Logger para registrar quando uma consulta é agendada
    private readonly ILogger<ConsultasController> _logger;

    public ConsultasController(IConsultaService service, ILogger<ConsultasController> logger)
    {
        _service = service;
        _logger = logger;
    }

    // Lista consultas com filtros opcionais: petId, veterinarioId, donoId, status, período.
    // Retorna resultado paginado.
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<PagedResult<ConsultaResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> Listar([FromQuery] ConsultaFiltro filtro, CancellationToken ct)
    {
        var result = await _service.ListarAsync(filtro, ct);
        return Ok(ApiResponse<PagedResult<ConsultaResponse>>.Ok(result, "Operacao realizada com sucesso."));
    }

    // Busca uma consulta específica pelo ID.
    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(ApiResponse<ConsultaResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> ObterPorId(Guid id, CancellationToken ct)
    {
        var result = await _service.ObterPorIdAsync(id, ct);
        return Ok(ApiResponse<ConsultaResponse>.Ok(result, "Operacao realizada com sucesso."));
    }

    // Retorna o histórico completo de consultas de um pet específico.
    // Útil para mostrar no app o histórico médico do animal.
    [HttpGet("pet/{petId:guid}")]
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<ConsultaResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> ObterPorPet(Guid petId, CancellationToken ct)
    {
        var result = await _service.ObterPorPetAsync(petId, ct);
        return Ok(ApiResponse<IEnumerable<ConsultaResponse>>.Ok(result, "Operacao realizada com sucesso."));
    }

    // Retorna a agenda completa de um veterinário (todas as consultas dele).
    // Usado no painel do veterinário para ver seus atendimentos.
    [HttpGet("veterinario/{veterinarioId:guid}")]
    [ProducesResponseType(typeof(ApiResponse<IEnumerable<ConsultaResponse>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> ObterPorVeterinario(Guid veterinarioId, CancellationToken ct)
    {
        var result = await _service.ObterPorVeterinarioAsync(veterinarioId, ct);
        return Ok(ApiResponse<IEnumerable<ConsultaResponse>>.Ok(result, "Operacao realizada com sucesso."));
    }

    // Agenda uma nova consulta para um pet com um veterinário.
    // Regras verificadas: data futura, sem conflito de horário para o vet e para o pet (janela de ±60min),
    // e o veterinário deve estar ativo. O status inicial é sempre "Agendada".
    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<ConsultaResponse>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Agendar([FromBody] CreateConsultaRequest request, CancellationToken ct)
    {
        var result = await _service.AgendarAsync(request, ct);
        _logger.LogInformation("Consulta agendada: {Id}", result.Id);
        return CreatedAtAction(nameof(ObterPorId), new { id = result.Id },
            ApiResponse<ConsultaResponse>.Ok(result, "Consulta agendada com sucesso."));
    }

    // Reagenda uma consulta já existente para uma nova data/horário.
    // Só é possível reagendar consultas com status "Agendada" ou "Confirmada".
    [HttpPut("{id:guid}")]
    [ProducesResponseType(typeof(ApiResponse<ConsultaResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Reagendar(Guid id, [FromBody] UpdateConsultaRequest request, CancellationToken ct)
    {
        var result = await _service.ReagendarAsync(id, request, ct);
        return Ok(ApiResponse<ConsultaResponse>.Ok(result, "Consulta reagendada com sucesso."));
    }

    // Confirma uma consulta agendada — muda o status de "Agendada" para "Confirmada".
    // Geralmente feito pelo veterinário ou admin para confirmar o atendimento.
    [HttpPatch("{id:guid}/confirmar")]
    [ProducesResponseType(typeof(ApiResponse<ConsultaResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Confirmar(Guid id, CancellationToken ct)
    {
        var result = await _service.ConfirmarAsync(id, ct);
        return Ok(ApiResponse<ConsultaResponse>.Ok(result, "Consulta confirmada com sucesso."));
    }

    // Cancela uma consulta — muda o status para "Cancelada" (estado terminal, não pode ser desfeito).
    // Requer um motivo de cancelamento no corpo da requisição.
    [HttpPatch("{id:guid}/cancelar")]
    [ProducesResponseType(typeof(ApiResponse<ConsultaResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Cancelar(Guid id, [FromBody] CancelarConsultaRequest request, CancellationToken ct)
    {
        var result = await _service.CancelarAsync(id, request, ct);
        return Ok(ApiResponse<ConsultaResponse>.Ok(result, "Consulta cancelada."));
    }

    // Finaliza uma consulta que foi realizada — muda o status para "Finalizada" (estado terminal).
    // Permite registrar observações finais sobre o atendimento.
    [HttpPatch("{id:guid}/finalizar")]
    [ProducesResponseType(typeof(ApiResponse<ConsultaResponse>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Finalizar(Guid id, [FromBody] FinalizarConsultaRequest request, CancellationToken ct)
    {
        var result = await _service.FinalizarAsync(id, request, ct);
        return Ok(ApiResponse<ConsultaResponse>.Ok(result, "Consulta finalizada com sucesso."));
    }
}
