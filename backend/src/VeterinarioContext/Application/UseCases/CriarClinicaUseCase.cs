using VetBook.VeterinarioContext.Application.DTOs;
using VetBook.VeterinarioContext.Application.Interfaces;
using VetBook.VeterinarioContext.Domain.Entities;
using VetBook.VeterinarioContext.Domain.Interfaces;

namespace VetBook.VeterinarioContext.Application.UseCases;

// Use Case responsável por criar uma nova clínica veterinária.
// Valida unicidade do nome antes de persistir.
public class CriarClinicaUseCase
{
    private readonly IClinicaRepository _repo;
    private readonly IVeterinarioUnitOfWork _uow;

    public CriarClinicaUseCase(IClinicaRepository repo, IVeterinarioUnitOfWork uow)
    {
        _repo = repo; _uow = uow;
    }

    public async Task<ClinicaResponse> ExecutarAsync(CreateClinicaRequest request, CancellationToken ct)
    {
        // Verifica se já existe uma clínica com o mesmo nome (unicidade)
        if (await _repo.NomeExisteAsync(request.Nome, null, ct))
            throw new InvalidOperationException($"Ja existe uma clinica com o nome '{request.Nome}'.");

        // Cria a entidade via factory method — nasce ativa por padrão
        var clinica = Clinica.Criar(request.Nome, request.Endereco, request.Telefone, request.Email);
        await _repo.AdicionarAsync(clinica, ct);
        await _uow.CommitAsync(ct);

        // Monta o DTO de resposta manualmente
        return new ClinicaResponse(clinica.Id, clinica.Nome, clinica.Endereco,
            clinica.Telefone, clinica.Email, clinica.Ativo, clinica.DataCadastro);
    }
}
