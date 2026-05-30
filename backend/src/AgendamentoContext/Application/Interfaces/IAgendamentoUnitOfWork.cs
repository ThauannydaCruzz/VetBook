using VetBook.SharedKernel.Interfaces;

namespace VetBook.AgendamentoContext.Application.Interfaces;

// Interface do Unit of Work específico do contexto de Agendamento.
// Herda de IUnitOfWork, que define o método CommitAsync para persistir mudanças.
// Mantida separada dos outros contextos para garantir isolamento entre bounded contexts.
public interface IAgendamentoUnitOfWork : IUnitOfWork { }
