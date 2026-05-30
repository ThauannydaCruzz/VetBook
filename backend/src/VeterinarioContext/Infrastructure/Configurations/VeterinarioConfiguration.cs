using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using VetBook.VeterinarioContext.Domain.Entities;

namespace VetBook.VeterinarioContext.Infrastructure.Configurations;

// Configuração do Entity Framework para a entidade Veterinario.
// Define o mapeamento para a tabela "Veterinarios" com colunas, índices e relacionamentos.
public class VeterinarioConfiguration : IEntityTypeConfiguration<Veterinario>
{
    public void Configure(EntityTypeBuilder<Veterinario> builder)
    {
        builder.ToTable("Veterinarios");
        builder.HasKey(v => v.Id);

        builder.Property(v => v.Nome).IsRequired().HasMaxLength(150);

        // CRMV é único — cada veterinário tem seu registro profissional exclusivo
        builder.Property(v => v.Crmv).IsRequired().HasMaxLength(20);
        builder.HasIndex(v => v.Crmv).IsUnique().HasDatabaseName("IX_Veterinarios_Crmv");

        builder.Property(v => v.Especialidade).IsRequired().HasMaxLength(100);

        // EmailValor é a string extraída do Value Object Email
        builder.Property(v => v.EmailValor).HasColumnName("Email").IsRequired().HasMaxLength(200);
        builder.Property(v => v.Telefone).IsRequired().HasMaxLength(20);
        builder.Property(v => v.Ativo).IsRequired().HasDefaultValue(true);
        builder.Property(v => v.DataCadastro).IsRequired();

        builder.Property(v => v.ClinicaId);

        // Relacionamento N:1 com Clinica — opcional (veterinário pode não ter clínica)
        // DeleteBehavior.SetNull: ao remover a clínica, ClinicaId fica null no veterinário
        builder.HasOne(v => v.Clinica)
            .WithMany()
            .HasForeignKey(v => v.ClinicaId)
            .IsRequired(false)
            .OnDelete(DeleteBehavior.SetNull);
    }
}
