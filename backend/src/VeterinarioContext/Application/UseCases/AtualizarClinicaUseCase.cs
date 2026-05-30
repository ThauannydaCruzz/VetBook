using VetBook.VeterinarioContext.Application.DTOs;
using VetBook.VeterinarioContext.Application.Interfaces;
using VetBook.VeterinarioContext.Domain.Interfaces;

namespace VetBook.VeterinarioContext.Application.UseCases;

// Use Case responsável por atualizar os dados de uma clínica veterinária.
// Valida que o novo nome não conflite com outra clínica já cadastrada.
public class AtualizarClinicaUseCase
{
    private readonly IClinicaRepository _repo;
    private readonly IVeterinarioUnitOfWork _uow;

    public AtualizarClinicaUseCase(IClinicaRepository repo, IVeterinarioUnitOfWork uow)
    {
        _repo = repo; _uow = uow;
    }

    public async Task<ClinicaResponse> ExecutarAsync(Guid id, UpdateClinicaRequest request, CancellationToken ct)
    {
        // Lança KeyNotFoundException se a clínica não existir
        var clinica = await _repo.ObterPorIdAsync(id, ct)
            ?? throw new KeyNotFoundException($"Clinica {id} nao encontrada.");

        // Verifica unicidade do nome — o ignorarId evita falso positivo com a própria clínica
        if (await _repo.NomeExisteAsync(request.Nome, id, ct))
            throw new InvalidOperationException($"Ja existe outra clinica com o nome '{request.Nome}'.");

        // Atualiza os dados e registra a data de atualização
        clinica.Atualizar(request.Nome, request.Endereco, request.Telefone, request.Email);
        await _uow.CommitAsync(ct);

        // Monta o DTO manualmente (sem AutoMapper aqui)
        return new ClinicaResponse(clinica.Id, clinica.Nome, clinica.Endereco,
            clinica.Telefone, clinica.Email, clinica.Ativo, clinica.DataCadastro);
    }
}
