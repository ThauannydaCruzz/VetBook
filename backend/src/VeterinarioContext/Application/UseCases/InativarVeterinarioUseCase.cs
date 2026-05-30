using VetBook.VeterinarioContext.Application.Interfaces;
using VetBook.VeterinarioContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.VeterinarioContext.Application.UseCases;

// Use Case responsável por inativar um veterinário.
// Veterinários inativos não aparecem nas opções de agendamento,
// mas mantêm todo o histórico de consultas preservado.
public class InativarVeterinarioUseCase
{
    private readonly IVeterinarioRepository _repository;
    private readonly IVeterinarioUnitOfWork _unitOfWork;

    public InativarVeterinarioUseCase(IVeterinarioRepository repository, IVeterinarioUnitOfWork unitOfWork)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
    }

    public async Task ExecuteAsync(Guid id, CancellationToken ct = default)
    {
        var vet = await _repository.ObterPorIdAsync(id, ct)
            ?? throw new NotFoundException("Veterinario", id);

        // A entidade encapsula a lógica de inativação e atualiza DataAtualizacao
        vet.Inativar();
        _repository.Atualizar(vet);
        await _unitOfWork.CommitAsync(ct);
    }
}
