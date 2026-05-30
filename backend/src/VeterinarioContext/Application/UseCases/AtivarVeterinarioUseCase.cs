using VetBook.VeterinarioContext.Application.Interfaces;
using VetBook.VeterinarioContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.VeterinarioContext.Application.UseCases;

// Use Case responsável por ativar um veterinário inativo.
// Após ativar, o veterinário volta a aparecer nas opções de agendamento.
public class AtivarVeterinarioUseCase
{
    private readonly IVeterinarioRepository _repository;
    private readonly IVeterinarioUnitOfWork _unitOfWork;

    public AtivarVeterinarioUseCase(IVeterinarioRepository repository, IVeterinarioUnitOfWork unitOfWork)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
    }

    public async Task ExecuteAsync(Guid id, CancellationToken ct = default)
    {
        // Lança NotFoundException se o veterinário não existir
        var vet = await _repository.ObterPorIdAsync(id, ct)
            ?? throw new NotFoundException("Veterinario", id);

        // A entidade encapsula a lógica de ativação e atualiza DataAtualizacao
        vet.Ativar();
        _repository.Atualizar(vet);
        await _unitOfWork.CommitAsync(ct);
    }
}
