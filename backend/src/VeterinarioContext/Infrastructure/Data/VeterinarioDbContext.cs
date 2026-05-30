using Microsoft.EntityFrameworkCore;
using VetBook.VeterinarioContext.Domain.Entities;

namespace VetBook.VeterinarioContext.Infrastructure.Data;

/* DbContext do contexto de Veterinário — contexto isolado que gerencia
 * apenas as tabelas Veterinarios e Clinicas.
 * As configurações de mapeamento são carregadas automaticamente via
 * ApplyConfigurationsFromAssembly, que detecta todas as classes IEntityTypeConfiguration<T>
 * no assembly. */
public class VeterinarioDbContext : DbContext
{
    public VeterinarioDbContext(DbContextOptions<VeterinarioDbContext> options) : base(options) { }

    // DbSets expõem as tabelas para queries LINQ no EF Core
    public DbSet<Veterinario> Veterinarios { get; set; } = default!;
    public DbSet<Clinica>     Clinicas     { get; set; } = default!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Aplica automaticamente todas as configurações do assembly
        // (ClinicaConfiguration e VeterinarioConfiguration)
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(VeterinarioDbContext).Assembly);
    }
}
