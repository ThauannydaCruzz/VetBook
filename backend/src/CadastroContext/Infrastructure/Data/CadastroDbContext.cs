using Microsoft.EntityFrameworkCore;
using VetBook.CadastroContext.Domain.Entities;

namespace VetBook.CadastroContext.Infrastructure.Data;

/* DbContext do módulo de Cadastro.
 * O Entity Framework usa esta classe para saber quais tabelas gerenciar
 * e como mapear as entidades de domínio para o banco de dados.
 * As configurações detalhadas (nomes de colunas, índices, etc.) ficam em classes separadas
 * de configuração, carregadas automaticamente pelo ApplyConfigurationsFromAssembly. */
public class CadastroDbContext : DbContext
{
    public CadastroDbContext(DbContextOptions<CadastroDbContext> options) : base(options) { }

    // Tabela de donos (tutores dos animais)
    public DbSet<Dono> Donos { get; set; } = default!;

    // Tabela de pets (animais cadastrados)
    public DbSet<Pet> Pets { get; set; } = default!;

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        // Carrega automaticamente todas as classes de configuração do assembly deste contexto
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(CadastroDbContext).Assembly);
    }
}
