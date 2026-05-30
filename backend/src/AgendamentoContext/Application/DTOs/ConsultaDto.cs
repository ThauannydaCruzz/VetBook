using VetBook.AgendamentoContext.Domain.Enums;

namespace VetBook.AgendamentoContext.Application.DTOs;

// DTO de entrada para agendar uma nova consulta.
// Contém os dados mínimos necessários: pet, veterinário, data e motivo.
public record CreateConsultaRequest(
    Guid PetId,
    Guid VeterinarioId,
    DateTime DataConsulta,
    string MotivoConsulta,
    string? Observacoes
);

// DTO de entrada para reagendar uma consulta existente.
// Permite alterar a data, motivo e observações sem criar nova consulta.
public record UpdateConsultaRequest(
    DateTime DataConsulta,
    string MotivoConsulta,
    string? Observacoes
);

// DTO para cancelar uma consulta — o motivo é opcional
public record CancelarConsultaRequest(string? MotivoCancelamento);

// DTO para finalizar uma consulta — observações finais são opcionais
public record FinalizarConsultaRequest(string? Observacoes);

// DTO de saída retornado após qualquer operação com consulta.
// Inclui os nomes do pet e veterinário para facilitar exibição no frontend.
public record ConsultaResponse
{
    public Guid Id { get; init; }
    public Guid PetId { get; init; }

    // Nome do pet — preenchido manualmente no Use Case (não mapeado via AutoMapper)
    public string? NomePet { get; init; }

    public Guid VeterinarioId { get; init; }

    // Nome do veterinário — preenchido manualmente no Use Case
    public string? NomeVeterinario { get; init; }

    public DateTime DataConsulta { get; init; }
    public string MotivoConsulta { get; init; } = string.Empty;

    // Status como string (ex: "Agendada", "Confirmada") — convertido do enum
    public string StatusConsulta { get; init; } = string.Empty;

    public string? Observacoes { get; init; }
    public DateTime DataCadastro { get; init; }
}
