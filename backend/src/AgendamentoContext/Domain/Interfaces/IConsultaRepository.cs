using VetBook.AgendamentoContext.Domain.Entities;
using VetBook.AgendamentoContext.Domain.Enums;
using VetBook.SharedKernel.Common;
using VetBook.SharedKernel.Interfaces;

namespace VetBook.AgendamentoContext.Domain.Interfaces;

// Interface do repositório de consultas — estende o repositório genérico
// com operações específicas do domínio de agendamento.
public interface IConsultaRepository : IRepository<Consulta>
{
    // Verifica se o veterinário já possui consulta no mesmo horário.
    // O parâmetro ignorarId evita falso positivo ao reagendar a própria consulta.
    Task<bool> ExisteConflitoPorVeterinarioAsync(Guid veterinarioId, DateTime dataConsulta,
        Guid? ignorarId = null, CancellationToken ct = default);

    // Verifica se o pet já possui consulta no mesmo horário
    Task<bool> ExisteConflitoPorPetAsync(Guid petId, DateTime dataConsulta,
        Guid? ignorarId = null, CancellationToken ct = default);

    // Retorna todas as consultas de um pet (histórico completo)
    Task<IEnumerable<Consulta>> ObterPorPetAsync(Guid petId, CancellationToken ct = default);

    // Retorna todas as consultas de um veterinário (agenda completa)
    Task<IEnumerable<Consulta>> ObterPorVeterinarioAsync(Guid veterinarioId, CancellationToken ct = default);

    // Lista consultas com paginação e filtros avançados (pet, vet, dono, status, período)
    Task<PagedResult<Consulta>> ListarAsync(ConsultaFiltro filtro, CancellationToken ct = default);
}

// Classe de filtro para listagem paginada de consultas.
// Herda de PagedQuery para incluir página, tamanho e ordenação.
public class ConsultaFiltro : PagedQuery
{
    public Guid? PetId { get; set; }
    public Guid? VeterinarioId { get; set; }
    public Guid? DonoId { get; set; }           // Filtra consultas dos pets de um dono
    public StatusConsulta? Status { get; set; }
    public DateTime? DataInicio { get; set; }   // Intervalo de datas para busca
    public DateTime? DataFim { get; set; }
}
