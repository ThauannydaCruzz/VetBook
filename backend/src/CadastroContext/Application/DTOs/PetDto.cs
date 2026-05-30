using VetBook.CadastroContext.Domain.Entities;

namespace VetBook.CadastroContext.Application.DTOs;

// DTO de entrada para criar um pet vinculado a um dono.
// O DonoId associa o pet ao seu tutor no momento do cadastro.
public record CreatePetRequest(
    string Nome,
    string Especie,
    string Raca,
    int Idade,
    decimal Peso,
    SexoPet Sexo,
    string? Observacoes,
    Guid DonoId  // ID do dono responsável pelo pet
);

// DTO de entrada para atualizar dados do pet.
// O DonoId não pode ser alterado — pet não muda de dono.
public record UpdatePetRequest(
    string Nome,
    string Especie,
    string Raca,
    int Idade,
    decimal Peso,
    SexoPet Sexo,
    string? Observacoes
);

// DTO de saída com os dados completos do pet.
// Inclui nome do dono para facilitar exibição em listagens.
public record PetResponse
{
    public Guid Id { get; init; }
    public string Nome { get; init; } = string.Empty;
    public string Especie { get; init; } = string.Empty;
    public string Raca { get; init; } = string.Empty;
    public int Idade { get; init; }
    public decimal Peso { get; init; }

    // Sexo convertido para string ("Macho" ou "Femea") pelo mapeamento
    public string Sexo { get; init; } = string.Empty;
    public string? Observacoes { get; init; }
    public Guid DonoId { get; init; }

    // Nome do dono — pode ser null se o pet for buscado sem carregar o dono
    public string? NomeDono { get; init; }
    public DateTime DataCadastro { get; init; }
}
