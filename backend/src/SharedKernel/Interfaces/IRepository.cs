using VetBook.SharedKernel.Entities;

namespace VetBook.SharedKernel.Interfaces;

/* Interface genérica de repositório — define o contrato CRUD básico
 * para todas as entidades do sistema.
 * A constraint "where T : BaseEntity" garante que apenas entidades
 * com Id e datas de auditoria possam ser usadas como parâmetro genérico. */
public interface IRepository<T> where T : BaseEntity
{
    // Busca uma entidade pelo ID — retorna null se não encontrar
    Task<T?> ObterPorIdAsync(Guid id, CancellationToken ct = default);

    // Retorna todas as entidades sem paginação — uso limitado a listas pequenas
    Task<IEnumerable<T>> ObterTodosAsync(CancellationToken ct = default);

    // Adiciona uma nova entidade ao contexto (ainda não persiste)
    Task AdicionarAsync(T entity, CancellationToken ct = default);

    // Marca a entidade como modificada no contexto (ainda não persiste)
    void Atualizar(T entity);

    // Marca a entidade para remoção no contexto (ainda não persiste)
    void Remover(T entity);
}
