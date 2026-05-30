using VetBook.SharedKernel.Interfaces;

namespace VetBook.VeterinarioContext.Application.Interfaces;

// Interface do Unit of Work específico do contexto de Veterinário.
// Mantida separada para isolar o DbContext de Veterinário dos outros contextos.
public interface IVeterinarioUnitOfWork : IUnitOfWork { }
