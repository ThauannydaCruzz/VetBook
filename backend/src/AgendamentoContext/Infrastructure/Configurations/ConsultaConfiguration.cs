using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using VetBook.AgendamentoContext.Domain.Entities;

namespace VetBook.AgendamentoContext.Infrastructure.Configurations;

// Configuração do Entity Framework para a entidade Consulta.
// Define o mapeamento para a tabela "Consultas" com suas colunas, constraints e índices.
public class ConsultaConfiguration : IEntityTypeConfiguration<Consulta>
{
    public void Configure(EntityTypeBuilder<Consulta> builder)
    {
        builder.ToTable("Consultas");
        builder.HasKey(c => c.Id);

        // Chaves estrangeiras para Pet e Veterinário — sem navegação direta
        // (consulta é um agregado independente)
        builder.Property(c => c.PetId).IsRequired();
        builder.Property(c => c.VeterinarioId).IsRequired();

        builder.Property(c => c.DataConsulta).IsRequired();

        // Motivo tem limite de 500 caracteres para evitar textos excessivos
        builder.Property(c => c.MotivoConsulta)
            .IsRequired()
            .HasMaxLength(500);

        // Status armazenado como string para legibilidade no banco
        // (ex: "Agendada" em vez de 1)
        builder.Property(c => c.StatusConsulta)
            .IsRequired()
            .HasConversion<string>()
            .HasMaxLength(20);

        builder.Property(c => c.Observacoes)
            .HasMaxLength(500);

        builder.Property(c => c.DataCadastro).IsRequired();

        // Índices para otimizar as queries mais frequentes:
        // busca por veterinário, por pet e por data
        builder.HasIndex(c => c.VeterinarioId)
            .HasDatabaseName("IX_Consultas_VeterinarioId");

        builder.HasIndex(c => c.PetId)
            .HasDatabaseName("IX_Consultas_PetId");

        builder.HasIndex(c => c.DataConsulta)
            .HasDatabaseName("IX_Consultas_DataConsulta");
    }
}
