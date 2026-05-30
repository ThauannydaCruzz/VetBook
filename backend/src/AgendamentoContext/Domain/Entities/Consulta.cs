using VetBook.AgendamentoContext.Domain.Enums;
using VetBook.SharedKernel.Entities;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.AgendamentoContext.Domain.Entities;

/* Entidade de domínio que representa uma Consulta veterinária.
 * Controla o ciclo de vida completo de um agendamento:
 * Agendada → Confirmada → Finalizada (ou Cancelada em qualquer etapa antes de finalizar).
 * Os métodos de transição (Confirmar, Cancelar, etc.) validam se a mudança é permitida. */
public class Consulta : BaseEntity
{
    // ID do pet que vai ser atendido
    public Guid PetId { get; private set; }

    // ID do veterinário que fará o atendimento
    public Guid VeterinarioId { get; private set; }

    // Data e hora agendada para a consulta (em UTC)
    public DateTime DataConsulta { get; private set; }

    // Motivo pelo qual a consulta foi agendada (ex: "Vacina anual", "Consulta de rotina")
    public string MotivoConsulta { get; private set; } = default!;

    // Estado atual da consulta no ciclo de vida
    public StatusConsulta StatusConsulta { get; private set; }

    // Campo livre para anotações — pode conter motivo de cancelamento ou observações do atendimento
    public string? Observacoes { get; private set; }

    // Construtor sem parâmetros necessário para o Entity Framework
    protected Consulta() { }

    // Construtor privado — só chamado pelo método fábrica Criar()
    private Consulta(Guid petId, Guid veterinarioId, DateTime dataConsulta,
                     string motivoConsulta, string? observacoes)
    {
        PetId = petId;
        VeterinarioId = veterinarioId;
        DataConsulta = dataConsulta;
        MotivoConsulta = motivoConsulta;
        Observacoes = observacoes;
        StatusConsulta = StatusConsulta.Agendada; // Status inicial sempre é "Agendada"
    }

    // Método fábrica — única forma de criar uma Consulta válida
    public static Consulta Criar(Guid petId, Guid veterinarioId, DateTime dataConsulta,
                                  string motivoConsulta, string? observacoes)
    {
        Validar(petId, veterinarioId, dataConsulta, motivoConsulta);
        return new Consulta(petId, veterinarioId, dataConsulta, motivoConsulta, observacoes);
    }

    // Transição: Agendada → Confirmada
    // Só é possível confirmar uma consulta que ainda está como "Agendada"
    public void Confirmar()
    {
        if (StatusConsulta != StatusConsulta.Agendada)
            throw new DomainException("Apenas consultas agendadas podem ser confirmadas.");
        StatusConsulta = StatusConsulta.Confirmada;
        SetUpdatedAt();
    }

    // Transição: Agendada/Confirmada → Cancelada (estado terminal)
    // Uma vez cancelada ou finalizada, a consulta não pode ser cancelada de novo
    public void Cancelar(string? motivoCancelamento = null)
    {
        if (StatusConsulta == StatusConsulta.Finalizada)
            throw new DomainException("Consulta finalizada nao pode ser cancelada.");
        if (StatusConsulta == StatusConsulta.Cancelada)
            throw new DomainException("Consulta ja esta cancelada.");

        StatusConsulta = StatusConsulta.Cancelada;
        // Registra o motivo do cancelamento nas observações, se informado
        if (motivoCancelamento is not null)
            Observacoes = motivoCancelamento;
        SetUpdatedAt();
    }

    // Transição: Confirmada → Finalizada (estado terminal)
    // Indica que a consulta foi realizada. Permite registrar observações do atendimento.
    public void Finalizar(string? observacoes = null)
    {
        if (StatusConsulta == StatusConsulta.Cancelada)
            throw new DomainException("Consulta cancelada nao pode ser finalizada.");
        if (StatusConsulta == StatusConsulta.Finalizada)
            throw new DomainException("Consulta ja esta finalizada.");

        StatusConsulta = StatusConsulta.Finalizada;
        if (observacoes is not null)
            Observacoes = observacoes;
        SetUpdatedAt();
    }

    // Permite alterar a data e o motivo de uma consulta que ainda não foi finalizada/cancelada
    public void Reagendar(DateTime novaData, string motivo)
    {
        if (StatusConsulta is StatusConsulta.Cancelada or StatusConsulta.Finalizada)
            throw new DomainException("Nao e possivel reagendar uma consulta cancelada ou finalizada.");
        if (novaData <= DateTime.UtcNow)
            throw new DomainException("A nova data da consulta deve ser futura.");

        DataConsulta = novaData;
        MotivoConsulta = motivo;
        SetUpdatedAt();
    }

    // Validações aplicadas na criação — garantem que a consulta começa em estado válido
    private static void Validar(Guid petId, Guid veterinarioId, DateTime dataConsulta, string motivo)
    {
        if (petId == Guid.Empty)
            throw new DomainException("Pet e obrigatorio.");
        if (veterinarioId == Guid.Empty)
            throw new DomainException("Veterinario e obrigatorio.");
        if (dataConsulta <= DateTime.UtcNow)
            throw new DomainException("A data da consulta deve ser futura.");
        if (string.IsNullOrWhiteSpace(motivo))
            throw new DomainException("Motivo da consulta e obrigatorio.");
        if (motivo.Length > 500)
            throw new DomainException("Motivo deve ter no maximo 500 caracteres.");
    }
}
