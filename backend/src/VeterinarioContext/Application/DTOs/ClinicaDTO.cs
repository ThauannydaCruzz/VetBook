namespace VetBook.VeterinarioContext.Application.DTOs;

// DTO de saída com os dados de uma clínica veterinária.
// Retornado em listagens e após operações de criação/atualização.
public record ClinicaResponse(
    Guid    Id,
    string  Nome,
    string  Endereco,
    string  Telefone,
    string? Email,     // E-mail é opcional na clínica
    bool    Ativo,     // Indica se a clínica está ativa e aceita agendamentos
    DateTime DataCadastro
);

// DTO de entrada para criar uma nova clínica.
// O campo Ativo não é informado — toda clínica nasce ativa.
public record CreateClinicaRequest(
    string  Nome,
    string  Endereco,
    string  Telefone,
    string? Email  // Opcional
);

// DTO de entrada para atualizar os dados de uma clínica existente
public record UpdateClinicaRequest(
    string  Nome,
    string  Endereco,
    string  Telefone,
    string? Email  // Opcional
);
