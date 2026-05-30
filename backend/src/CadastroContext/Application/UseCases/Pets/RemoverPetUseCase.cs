using VetBook.CadastroContext.Application.Interfaces;
using VetBook.CadastroContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.CadastroContext.Application.UseCases.Pets;

// Use Case responsável por remover um pet do sistema.
// Regra de negócio: não é possível remover pet com consultas futuras agendadas.
// Isso evita que o dono perca o histórico de agendamentos pendentes.
public class RemoverPetUseCase
{
    private readonly IPetRepository _repository;
    private readonly ICadastroUnitOfWork _unitOfWork;

    public RemoverPetUseCase(IPetRepository repository, ICadastroUnitOfWork unitOfWork)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
    }

    public async Task ExecuteAsync(Guid id, CancellationToken ct = default)
    {
        // Busca o pet — lança NotFoundException se não encontrar
        var pet = await _repository.ObterPorIdAsync(id, ct)
            ?? throw new NotFoundException("Pet", id);

        // Verifica consultas futuras — impede remoção se houver agendamentos pendentes
        if (await _repository.PossuiConsultasFuturasAsync(id, ct))
            throw new DomainException("Nao e possivel remover um pet que possui consultas futuras agendadas.");

        _repository.Remover(pet);
        await _unitOfWork.CommitAsync(ct);
    }
}
