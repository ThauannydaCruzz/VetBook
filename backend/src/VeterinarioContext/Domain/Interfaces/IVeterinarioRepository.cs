using VetBook.SharedKernel.Common;
using VetBook.SharedKernel.Interfaces;
using VetBook.VeterinarioContext.Domain.Entities;

namespace VetBook.VeterinarioContext.Domain.Interfaces;

// Interface do repositório de veterinários — estende o repositório genérico
// com operações específicas do domínio veterinário.
public interface IVeterinarioRepository : IRepository<Veterinario>
{
    // Verifica unicidade do CRMV — ignorarId exclui o próprio vet ao atualizar
    Task<bool> CrmvExisteAsync(string crmv, Guid? ignorarId = null, CancellationToken ct = default);

    // Lista veterinários com paginação e filtros múltiplos
    Task<PagedResult<Veterinario>> ListarAsync(VeterinarioFiltro filtro, CancellationToken ct = default);

    // Retorna todos os veterinários ativos — sem paginação, para dropdown
    Task<IEnumerable<Veterinario>> ListarAtivosAsync(CancellationToken ct = default);
}

// Classe de filtro para listagem paginada de veterinários.
// Herda de PagedQuery para incluir paginação e ordenação.
public class VeterinarioFiltro : PagedQuery
{
    public string? Nome { get; set; }
    public string? Crmv { get; set; }
    public string? Especialidade { get; set; }
    public bool? Ativo { get; set; }  // null = todos, true = ativos, false = inativos
}
