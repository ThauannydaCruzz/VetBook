using VetBook.CadastroContext.Domain.Entities;
using VetBook.SharedKernel.Common;
using VetBook.SharedKernel.Interfaces;

namespace VetBook.CadastroContext.Domain.Interfaces;

// Interface do repositório de pets — estende o repositório genérico
// com operações específicas do domínio de cadastro.
public interface IPetRepository : IRepository<Pet>
{
    // Retorna todos os pets pertencentes a um dono (sem paginação)
    Task<IEnumerable<Pet>> ObterPorDonoAsync(Guid donoId, CancellationToken ct = default);

    // Lista pets com paginação e filtros (nome, espécie, raça, donoId)
    Task<PagedResult<Pet>> ListarAsync(PetFiltro filtro, CancellationToken ct = default);

    // Verifica se o pet tem consultas futuras agendadas — usado antes da remoção
    Task<bool> PossuiConsultasFuturasAsync(Guid petId, CancellationToken ct = default);
}

// Classe de filtro para listagem paginada de pets.
public class PetFiltro : PagedQuery
{
    public string? Nome { get; set; }
    public string? Especie { get; set; }
    public string? Raca { get; set; }
    public Guid? DonoId { get; set; }  // Filtra pets de um dono específico
}
