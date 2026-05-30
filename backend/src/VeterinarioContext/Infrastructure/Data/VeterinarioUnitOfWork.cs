using VetBook.VeterinarioContext.Application.Interfaces;
using VetBook.SharedKernel.Interfaces;

namespace VetBook.VeterinarioContext.Infrastructure.Data;

/* Implementação do Unit of Work para o contexto de Veterinário.
 * Encapsula o VeterinarioDbContext garantindo que operações em
 * veterinários e clínicas sejam persistidas atomicamente. */
public class VeterinarioUnitOfWork : IVeterinarioUnitOfWork
{
    private readonly VeterinarioDbContext _context;
    private bool _disposed;

    public VeterinarioUnitOfWork(VeterinarioDbContext context) => _context = context;

    // Persiste todas as mudanças rastreadas pelo EF Core em uma transação
    public async Task<int> CommitAsync(CancellationToken ct = default)
        => await _context.SaveChangesAsync(ct);

    // Libera o DbContext e a conexão com o banco
    public void Dispose()
    {
        if (!_disposed) { _context.Dispose(); _disposed = true; }
    }
}
