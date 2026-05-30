using VetBook.AgendamentoContext.Application.DTOs;
using VetBook.AgendamentoContext.Domain.Interfaces;
using VetBook.SharedKernel.Common;

namespace VetBook.AgendamentoContext.Application.Interfaces;

// Interface de serviço de consultas — fachada que agrupa todas as operações possíveis.
// Implementada por ConsultaService, que delega para os Use Cases específicos.
public interface IConsultaService
{
    // Agenda uma nova consulta validando conflitos de horário
    Task<ConsultaResponse> AgendarAsync(CreateConsultaRequest request, CancellationToken ct = default);

    // Reagenda uma consulta existente para nova data/hora
    Task<ConsultaResponse> ReagendarAsync(Guid id, UpdateConsultaRequest request, CancellationToken ct = default);

    // Confirma uma consulta agendada (status: Agendada → Confirmada)
    Task<ConsultaResponse> ConfirmarAsync(Guid id, CancellationToken ct = default);

    // Cancela uma consulta com motivo opcional
    Task<ConsultaResponse> CancelarAsync(Guid id, CancelarConsultaRequest request, CancellationToken ct = default);

    // Finaliza uma consulta após o atendimento (status: Confirmada → Finalizada)
    Task<ConsultaResponse> FinalizarAsync(Guid id, FinalizarConsultaRequest request, CancellationToken ct = default);

    // Busca uma consulta pelo seu ID único
    Task<ConsultaResponse> ObterPorIdAsync(Guid id, CancellationToken ct = default);

    // Lista consultas com filtro e paginação
    Task<PagedResult<ConsultaResponse>> ListarAsync(ConsultaFiltro filtro, CancellationToken ct = default);

    // Retorna todas as consultas de um determinado pet
    Task<IEnumerable<ConsultaResponse>> ObterPorPetAsync(Guid petId, CancellationToken ct = default);

    // Retorna todas as consultas de um determinado veterinário
    Task<IEnumerable<ConsultaResponse>> ObterPorVeterinarioAsync(Guid veterinarioId, CancellationToken ct = default);
}
