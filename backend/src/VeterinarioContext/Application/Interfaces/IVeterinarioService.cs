using VetBook.SharedKernel.Common;
using VetBook.VeterinarioContext.Application.DTOs;
using VetBook.VeterinarioContext.Domain.Interfaces;

namespace VetBook.VeterinarioContext.Application.Interfaces;

// Interface de serviço de veterinários — fachada para todos os Use Cases.
// Implementada por VeterinarioService e consumida pelos Controllers da API.
public interface IVeterinarioService
{
    // Cria um veterinário validando unicidade do CRMV e existência da clínica
    Task<VeterinarioResponse> CriarAsync(CreateVeterinarioRequest request, CancellationToken ct = default);

    // Atualiza dados do veterinário (exceto CRMV)
    Task<VeterinarioResponse> AtualizarAsync(Guid id, UpdateVeterinarioRequest request, CancellationToken ct = default);

    // Ativa um veterinário inativo — permite que receba agendamentos novamente
    Task AtivarAsync(Guid id, CancellationToken ct = default);

    // Inativa um veterinário — impede novos agendamentos mas mantém histórico
    Task InativarAsync(Guid id, CancellationToken ct = default);

    // Remove um veterinário permanentemente do sistema
    Task RemoverAsync(Guid id, CancellationToken ct = default);

    // Busca um veterinário pelo ID
    Task<VeterinarioResponse> ObterPorIdAsync(Guid id, CancellationToken ct = default);

    // Lista veterinários com paginação e filtros (nome, CRMV, especialidade, status)
    Task<PagedResult<VeterinarioResponse>> ListarAsync(VeterinarioFiltro filtro, CancellationToken ct = default);

    // Retorna todos os veterinários ativos — usado no agendamento para selecionar profissional
    Task<IEnumerable<VeterinarioResponse>> ListarAtivosAsync(CancellationToken ct = default);
}
