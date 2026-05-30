using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using VetBook.CadastroContext.Domain.Entities;

namespace VetBook.CadastroContext.Infrastructure.Configurations;

// Configuração do Entity Framework para a entidade Dono.
// Define como a classe Dono é mapeada para a tabela "Donos" no banco de dados.
public class DonoConfiguration : IEntityTypeConfiguration<Dono>
{
    public void Configure(EntityTypeBuilder<Dono> builder)
    {
        builder.ToTable("Donos");
        builder.HasKey(d => d.Id);

        builder.Property(d => d.Nome).IsRequired().HasMaxLength(150);

        // CpfValor é a propriedade do Value Object Cpf — armazenado como string de 11 dígitos
        builder.Property(d => d.CpfValor)
            .HasColumnName("Cpf").IsRequired().HasMaxLength(11);
        // Índice único no CPF garante que não haja dois donos com o mesmo CPF
        builder.HasIndex(d => d.CpfValor).IsUnique().HasDatabaseName("IX_Donos_Cpf");

        // EmailValor é a propriedade do Value Object Email — sempre em lowercase
        builder.Property(d => d.EmailValor)
            .HasColumnName("Email").IsRequired().HasMaxLength(200);

        builder.Property(d => d.Telefone).IsRequired().HasMaxLength(20);
        builder.Property(d => d.Endereco).IsRequired().HasMaxLength(300);
        builder.Property(d => d.SenhaHash).IsRequired().HasMaxLength(100);
        builder.Property(d => d.DataCadastro).IsRequired();

        // Relacionamento 1:N com Pets — um dono tem muitos pets
        // DeleteBehavior.Restrict impede exclusão em cascata (precisa remover pets primeiro)
        builder.HasMany(d => d.Pets)
            .WithOne(p => p.Dono)
            .HasForeignKey(p => p.DonoId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
