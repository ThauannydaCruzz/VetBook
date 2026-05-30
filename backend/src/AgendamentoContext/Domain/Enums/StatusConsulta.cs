namespace VetBook.AgendamentoContext.Domain.Enums;

/* Enum que representa o ciclo de vida de uma consulta veterinária.
 * O fluxo esperado é: Agendada → Confirmada → Finalizada
 * Em qualquer estado antes de Finalizada, pode ser Cancelada.
 * Os valores numéricos garantem consistência no banco de dados. */
public enum StatusConsulta
{
    Agendada   = 1, // Consulta criada, aguardando confirmação
    Confirmada = 2, // Confirmada pela clínica ou veterinário
    Cancelada  = 3, // Cancelada pelo dono ou pelo administrador
    Finalizada = 4  // Atendimento concluído
}
