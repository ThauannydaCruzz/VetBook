using AutoMapper;
using VetBook.VeterinarioContext.Application.DTOs;
using VetBook.VeterinarioContext.Application.Interfaces;
using VetBook.VeterinarioContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.VeterinarioContext.Application.UseCases;

// Use Case responsável por atualizar os dados de um veterinário.
// Valida existência da clínica se informada e retorna o nome da clínica no response.
public class AtualizarVeterinarioUseCase
{
    private readonly IVeterinarioRepository _repository;
    private readonly IClinicaRepository     _clinicaRepo;
    private readonly IVeterinarioUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public AtualizarVeterinarioUseCase(IVeterinarioRepository repository, IClinicaRepository clinicaRepo,
                                       IVeterinarioUnitOfWork unitOfWork, IMapper mapper)
    {
        _repository  = repository;
        _clinicaRepo = clinicaRepo;
        _unitOfWork  = unitOfWork;
        _mapper      = mapper;
    }

    public async Task<VeterinarioResponse> ExecuteAsync(Guid id, UpdateVeterinarioRequest request, CancellationToken ct = default)
    {
        // Busca o veterinário — lança NotFoundException se não existir
        var vet = await _repository.ObterPorIdAsync(id, ct)
            ?? throw new NotFoundException("Veterinario", id);

        // Se uma nova clínica for informada, valida que ela existe
        string? clinicaNome = null;
        if (request.ClinicaId.HasValue)
        {
            var clinica = await _clinicaRepo.ObterPorIdAsync(request.ClinicaId.Value, ct)
                ?? throw new NotFoundException("Clinica", request.ClinicaId.Value);
            clinicaNome = clinica.Nome;
        }

        vet.Atualizar(request.Nome, request.Especialidade, request.Email, request.Telefone, request.ClinicaId);
        _repository.Atualizar(vet);
        await _unitOfWork.CommitAsync(ct);

        // Usa "with" do record para adicionar o ClinicaNome ao response mapeado
        var resp = _mapper.Map<VeterinarioResponse>(vet);
        return resp with { ClinicaNome = clinicaNome };
    }
}
