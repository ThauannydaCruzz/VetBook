namespace VetBook.VeterinarioContext.Application.DTOs;

// DTO de entrada para criar um novo veterinário.
// A clínica é opcional — veterinário pode ser cadastrado sem vínculo inicial.
public record CreateVeterinarioRequest(
    string  Nome,
    string  Crmv,           // Registro no Conselho Regional de Medicina Veterinária
    string  Especialidade,
    string  Email,
    string  Telefone,
    Guid?   ClinicaId = null  // Vínculo opcional com clínica
);

// DTO de entrada para atualizar veterinário.
// CRMV não pode ser alterado — é o identificador profissional imutável.
public record UpdateVeterinarioRequest(
    string  Nome,
    string  Especialidade,
    string  Email,
    string  Telefone,
    Guid?   ClinicaId = null  // Pode alterar a clínica ou desvincular (null)
);

// DTO de saída com todos os dados do veterinário.
// Inclui nome da clínica para evitar request adicional no frontend.
public record VeterinarioResponse
{
    public Guid     Id           { get; init; }
    public string   Nome         { get; init; } = string.Empty;
    public string   Crmv         { get; init; } = string.Empty;
    public string   Especialidade { get; init; } = string.Empty;

    // Email vem do Value Object Email (lowercase)
    public string   Email        { get; init; } = string.Empty;
    public string   Telefone     { get; init; } = string.Empty;
    public bool     Ativo        { get; init; }
    public Guid?    ClinicaId    { get; init; }

    // Nome da clínica — null se veterinário não tiver vínculo
    public string?  ClinicaNome  { get; init; }
    public DateTime DataCadastro { get; init; }
}
