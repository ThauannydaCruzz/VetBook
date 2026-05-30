using Microsoft.EntityFrameworkCore;
using VetBook.AgendamentoContext.Domain.Entities;

namespace VetBook.AgendamentoContext.Infrastructure.Data;

/* DbContext do módulo de Agendamento.
 * Gerencia apenas a tabela de Consultas — seguindo o princípio do DDD,
 * cada contexto delimitado (Bounded Context) tem seu próprio DbContext
 * e não mistura tabelas de outros contextos. */
public class AgendamentoDbContext : DbContext
{
    public AgendamentoDbContext(DbContextOptions<AgendamentoDbContext> options) : base(options) { }

    // Tabela de consultas veterinárias
    public DbSet<Consulta> Consultas { get; set; } = default!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        // Carrega as configurações de mapeamento do assembly deste contexto
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AgendamentoDbContext).Assembly);
    }
}
