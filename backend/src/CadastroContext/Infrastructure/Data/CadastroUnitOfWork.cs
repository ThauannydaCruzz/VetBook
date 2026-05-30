using VetBook.CadastroContext.Application.Interfaces;
using VetBook.SharedKernel.Interfaces;

namespace VetBook.CadastroContext.Infrastructure.Data;

/* Implementação do Unit of Work para o contexto de Cadastro.
 * Encapsula o CadastroDbContext e garante que todas as mudanças
 * (criação de donos, pets, etc.) sejam persistidas atomicamente.
 * O flag _disposed protege contra descarte duplo do DbContext. */
public class CadastroUnitOfWork : ICadastroUnitOfWork
{
    private readonly CadastroDbContext _context;
    private bool _disposed;

    public CadastroUnitOfWork(CadastroDbContext context) => _context = context;

    // Persiste todas as mudanças rastreadas pelo EF Core em uma transação
    public async Task<int> CommitAsync(CancellationToken ct = default)
        => await _context.SaveChangesAsync(ct);

    // Descarta o DbContext liberando a conexão com o banco
    public void Dispose()
    {
        if (!_disposed) { _context.Dispose(); _disposed = true; }
    }
}
