using VetBook.SharedKernel.Interfaces;

namespace VetBook.CadastroContext.Application.Interfaces;

// Interface do Unit of Work específico do contexto de Cadastro.
// Herda o método CommitAsync do IUnitOfWork e mantém o contexto isolado
// dos outros bounded contexts (Agendamento e Veterinário).
public interface ICadastroUnitOfWork : IUnitOfWork { }
