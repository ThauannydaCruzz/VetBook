using VetBook.CadastroContext.Application.Interfaces;
using VetBook.CadastroContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.CadastroContext.Application.UseCases.Donos;

// Use Case responsável por remover um dono do sistema.
// Regra de negócio: não é possível remover um dono que ainda possui pets cadastrados.
public class RemoverDonoUseCase
{
    private readonly IDonoRepository _repository;
    private readonly ICadastroUnitOfWork _unitOfWork;

    public RemoverDonoUseCase(IDonoRepository repository, ICadastroUnitOfWork unitOfWork)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
    }

    public async Task ExecuteAsync(Guid id, CancellationToken ct = default)
    {
        // Busca o dono com seus pets para verificar a regra de remoção
        var dono = await _repository.ObterComPetsAsync(id, ct)
            ?? throw new NotFoundException("Dono", id);

        // Bloqueia remoção se o dono ainda tiver pets — protege integridade dos dados
        if (dono.Pets.Any())
            throw new DomainException("Nao e possivel remover um dono que possui pets cadastrados.");

        _repository.Remover(dono);
        await _unitOfWork.CommitAsync(ct);
    }
}
