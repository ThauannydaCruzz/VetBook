using AutoMapper;
using VetBook.VeterinarioContext.Application.DTOs;
using VetBook.VeterinarioContext.Application.Interfaces;
using VetBook.VeterinarioContext.Domain.Entities;
using VetBook.VeterinarioContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.VeterinarioContext.Application.UseCases;

// Use Case responsável por criar um novo veterinário.
// Valida unicidade do CRMV e existência da clínica (se informada).
public class CriarVeterinarioUseCase
{
    private readonly IVeterinarioRepository _repository;
    private readonly IClinicaRepository     _clinicaRepo;
    private readonly IVeterinarioUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public CriarVeterinarioUseCase(IVeterinarioRepository repository, IClinicaRepository clinicaRepo,
                                   IVeterinarioUnitOfWork unitOfWork, IMapper mapper)
    {
        _repository  = repository;
        _clinicaRepo = clinicaRepo;
        _unitOfWork  = unitOfWork;
        _mapper      = mapper;
    }

    public async Task<VeterinarioResponse> ExecuteAsync(CreateVeterinarioRequest request, CancellationToken ct = default)
    {
        // CRMV é único no sistema — cada veterinário tem registro profissional distinto
        if (await _repository.CrmvExisteAsync(request.Crmv, null, ct))
            throw new DomainException($"CRMV {request.Crmv} ja esta cadastrado.");

        // Se clínica informada, valida existência antes de criar o vínculo
        Clinica? clinica = null;
        if (request.ClinicaId.HasValue)
        {
            clinica = await _clinicaRepo.ObterPorIdAsync(request.ClinicaId.Value, ct)
                ?? throw new NotFoundException("Clinica", request.ClinicaId.Value);
        }

        // Cria o veterinário via factory method — nasce ativo por padrão
        var vet = Veterinario.Criar(request.Nome, request.Crmv, request.Especialidade,
                                    request.Email, request.Telefone, request.ClinicaId);

        await _repository.AdicionarAsync(vet, ct);
        await _unitOfWork.CommitAsync(ct);

        // Usa "with" para enriquecer o response com os dados da clínica
        var resp = _mapper.Map<VeterinarioResponse>(vet);
        return resp with { ClinicaId = clinica?.Id, ClinicaNome = clinica?.Nome };
    }
}
