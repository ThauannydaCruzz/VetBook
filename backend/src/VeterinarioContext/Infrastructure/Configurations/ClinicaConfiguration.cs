using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using VetBook.VeterinarioContext.Domain.Entities;

namespace VetBook.VeterinarioContext.Infrastructure.Configurations;

// Configuração do Entity Framework para a entidade Clinica.
// Define o mapeamento para a tabela "Clinicas" com suas colunas e índices.
public class ClinicaConfiguration : IEntityTypeConfiguration<Clinica>
{
    public void Configure(EntityTypeBuilder<Clinica> builder)
    {
        builder.ToTable("Clinicas");
        builder.HasKey(c => c.Id);

        builder.Property(c => c.Nome).IsRequired().HasMaxLength(200);
        builder.Property(c => c.Endereco).IsRequired().HasMaxLength(400);
        builder.Property(c => c.Telefone).IsRequired().HasMaxLength(20);
        builder.Property(c => c.Email).HasMaxLength(200);  // Opcional — sem IsRequired

        // Ativo com valor padrão true — toda clínica nasce ativa
        builder.Property(c => c.Ativo).IsRequired().HasDefaultValue(true);
        builder.Property(c => c.DataCadastro).IsRequired();

        // Índice único no Nome — não pode ter duas clínicas com o mesmo nome
        builder.HasIndex(c => c.Nome).IsUnique().HasDatabaseName("IX_Clinicas_Nome");
    }
}
