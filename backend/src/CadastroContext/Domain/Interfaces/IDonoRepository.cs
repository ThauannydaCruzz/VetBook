using VetBook.CadastroContext.Domain.Entities;
using VetBook.SharedKernel.Common;
using VetBook.SharedKernel.Interfaces;

namespace VetBook.CadastroContext.Domain.Interfaces;

// Interface do repositório de donos — estende o repositório genérico
// com operações específicas do domínio de cadastro.
public interface IDonoRepository : IRepository<Dono>
{
    // Verifica se já existe outro dono com o mesmo CPF (unicidade).
    // O ignorarId permite excluir o próprio dono da verificação ao atualizar.
    Task<bool> CpfExisteAsync(string cpf, Guid? ignorarId = null, CancellationToken ct = default);

    // Busca um dono incluindo sua coleção de pets (eager loading via JOIN)
    Task<Dono?> ObterComPetsAsync(Guid id, CancellationToken ct = default);

    // Busca um dono pelo CPF — usado na autenticação/login
    Task<Dono?> ObterPorCpfAsync(string cpf, CancellationToken ct = default);

    // Lista donos com paginação e filtros (nome, CPF, email)
    Task<PagedResult<Dono>> ListarAsync(DonoFiltro filtro, CancellationToken ct = default);
}

// Classe de filtro para listagem paginada de donos.
// Herda de PagedQuery para incluir página, tamanho e ordenação.
public class DonoFiltro : PagedQuery
{
    public string? Nome { get; set; }
    public string? Cpf { get; set; }
    public string? Email { get; set; }
}
