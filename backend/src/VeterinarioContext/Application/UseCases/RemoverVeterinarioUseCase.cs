using VetBook.VeterinarioContext.Application.Interfaces;
using VetBook.VeterinarioContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.VeterinarioContext.Application.UseCases;

// Use Case responsável por remover permanentemente um veterinário do sistema.
// Recomenda-se inativar em vez de remover para preservar histórico de consultas.
public class RemoverVeterinarioUseCase
{
    private readonly IVeterinarioRepository _repository;
    private readonly IVeterinarioUnitOfWork _unitOfWork;

    public RemoverVeterinarioUseCase(IVeterinarioRepository repository, IVeterinarioUnitOfWork unitOfWork)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
    }

    public async Task ExecuteAsync(Guid id, CancellationToken ct = default)
    {
        var vet = await _repository.ObterPorIdAsync(id, ct)
            ?? throw new NotFoundException("Veterinario", id);

        _repository.Remover(vet);
        await _unitOfWork.CommitAsync(ct);
    }
}
