using VetBook.VeterinarioContext.Domain.Entities;
using VetBook.SharedKernel.Common;

namespace VetBook.VeterinarioContext.Domain.Interfaces;

// Interface do repositório de clínicas.
// Diferente dos outros repositórios, não herda de IRepository<T>
// pois a Clinica não herda de BaseEntity (tem sua própria estrutura de IDs).
public interface IClinicaRepository
{
    // Busca uma clínica pelo ID — retorna null se não encontrar
    Task<Clinica?> ObterPorIdAsync(Guid id, CancellationToken ct = default);

    // Lista clínicas com paginação e busca por nome ou endereço
    Task<PagedResult<Clinica>> ListarAsync(int page, int pageSize, string? busca, CancellationToken ct = default);

    // Retorna todas as clínicas ativas ordenadas por nome — usado no agendamento
    Task<List<Clinica>> ListarAtivasAsync(CancellationToken ct = default);

    // Verifica unicidade do nome — ignorarId exclui a própria clínica ao atualizar
    Task<bool> NomeExisteAsync(string nome, Guid? ignorarId, CancellationToken ct = default);

    // Adiciona a clínica ao contexto do EF (sem persistir ainda)
    Task AdicionarAsync(Clinica clinica, CancellationToken ct = default);

    // Remove a clínica do contexto do EF (sem persistir ainda)
    Task RemoverAsync(Clinica clinica, CancellationToken ct = default);
}
