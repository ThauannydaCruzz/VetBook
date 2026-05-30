using VetBook.AgendamentoContext.Application.Interfaces;
using VetBook.SharedKernel.Interfaces;

namespace VetBook.AgendamentoContext.Infrastructure.Data;

/* Implementação do Unit of Work para o contexto de Agendamento.
 * Encapsula o AgendamentoDbContext e garante que todas as mudanças
 * sejam persistidas atomicamente com uma única chamada a CommitAsync.
 * O padrão Dispose evita que o DbContext seja descartado mais de uma vez. */
public class AgendamentoUnitOfWork : IAgendamentoUnitOfWork
{
    private readonly AgendamentoDbContext _context;
    private bool _disposed;

    public AgendamentoUnitOfWork(AgendamentoDbContext context) => _context = context;

    // Persiste todas as mudanças rastreadas pelo EF Core no banco de dados
    public async Task<int> CommitAsync(CancellationToken ct = default)
        => await _context.SaveChangesAsync(ct);

    // Libera o DbContext da memória — só descarta uma vez (proteção com _disposed)
    public void Dispose()
    {
        if (!_disposed) { _context.Dispose(); _disposed = true; }
    }
}
