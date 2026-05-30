namespace VetBook.SharedKernel.Interfaces;

/* Interface do padrão Unit of Work — garante que múltiplas operações
 * de repositório sejam persistidas em uma única transação atômica.
 * Herda IDisposable para liberar recursos do DbContext corretamente. */
public interface IUnitOfWork : IDisposable
{
    // Persiste todas as mudanças rastreadas pelo EF Core no banco de dados.
    // Retorna o número de registros afetados.
    Task<int> CommitAsync(CancellationToken ct = default);
}
