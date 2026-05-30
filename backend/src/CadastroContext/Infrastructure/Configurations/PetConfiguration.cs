using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using VetBook.CadastroContext.Domain.Entities;

namespace VetBook.CadastroContext.Infrastructure.Configurations;

// Configuração do Entity Framework para a entidade Pet.
// Define o mapeamento para a tabela "Pets" com suas colunas e constraints.
public class PetConfiguration : IEntityTypeConfiguration<Pet>
{
    public void Configure(EntityTypeBuilder<Pet> builder)
    {
        builder.ToTable("Pets");
        builder.HasKey(p => p.Id);

        builder.Property(p => p.Nome)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(p => p.Especie)
            .IsRequired()
            .HasMaxLength(50);

        builder.Property(p => p.Raca)
            .IsRequired()
            .HasMaxLength(50);

        builder.Property(p => p.Idade).IsRequired();
        builder.Property(p => p.Peso).IsRequired();

        // Sexo armazenado como string ("Macho" / "Femea") para legibilidade no banco
        builder.Property(p => p.Sexo)
            .IsRequired()
            .HasConversion<string>()
            .HasMaxLength(10);

        builder.Property(p => p.Observacoes)
            .HasMaxLength(500);

        builder.Property(p => p.DonoId).IsRequired();
        builder.Property(p => p.DataCadastro).IsRequired();

        // Índice no DonoId para acelerar queries de "pets por dono"
        builder.HasIndex(p => p.DonoId)
            .HasDatabaseName("IX_Pets_DonoId");
    }
}
