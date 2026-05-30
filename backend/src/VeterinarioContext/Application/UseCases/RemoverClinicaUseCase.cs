using VetBook.VeterinarioContext.Application.Interfaces;
using VetBook.VeterinarioContext.Domain.Interfaces;

namespace VetBook.VeterinarioContext.Application.UseCases;

// Use Case responsável por remover uma clínica do sistema.
// Atenção: ao remover, veterinários vinculados ficam sem clínica (ClinicaId → null)
// graças ao DeleteBehavior.SetNull configurado no EF Core.
public class RemoverClinicaUseCase
{
    private readonly IClinicaRepository _repo;
    private readonly IVeterinarioUnitOfWork _uow;

    public RemoverClinicaUseCase(IClinicaRepository repo, IVeterinarioUnitOfWork uow)
    {
        _repo = repo; _uow = uow;
    }

    public async Task ExecutarAsync(Guid id, CancellationToken ct)
    {
        // Lança KeyNotFoundException se a clínica não existir
        var clinica = await _repo.ObterPorIdAsync(id, ct)
            ?? throw new KeyNotFoundException($"Clinica {id} nao encontrada.");

        // Remove a clínica e commita — veterinários vinculados perdem o vínculo automaticamente
        await _repo.RemoverAsync(clinica, ct);
        await _uow.CommitAsync(ct);
    }
}
