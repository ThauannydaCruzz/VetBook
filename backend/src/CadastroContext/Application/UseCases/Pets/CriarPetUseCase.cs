using AutoMapper;
using VetBook.CadastroContext.Application.DTOs;
using VetBook.CadastroContext.Application.Interfaces;
using VetBook.CadastroContext.Domain.Entities;
using VetBook.CadastroContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.CadastroContext.Application.UseCases.Pets;

// Use Case responsável por cadastrar um novo pet no sistema.
// Valida que o dono existe antes de criar o pet — garantindo integridade referencial.
public class CriarPetUseCase
{
    private readonly IPetRepository _repository;
    private readonly IDonoRepository _donoRepository;  // Usado para validar existência do dono
    private readonly ICadastroUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public CriarPetUseCase(IPetRepository repository, IDonoRepository donoRepository,
                           ICadastroUnitOfWork unitOfWork, IMapper mapper)
    {
        _repository      = repository;
        _donoRepository  = donoRepository;
        _unitOfWork      = unitOfWork;
        _mapper          = mapper;
    }

    public async Task<PetResponse> ExecuteAsync(CreatePetRequest request, CancellationToken ct = default)
    {
        // Valida se o dono existe — lança NotFoundException se não encontrar
        var dono = await _donoRepository.ObterPorIdAsync(request.DonoId, ct);
        if (dono == null)
            throw new NotFoundException("Dono", request.DonoId);

        // Cria a entidade Pet via factory method (encapsula validações de domínio)
        var pet = Pet.Criar(request.Nome, request.Especie, request.Raca,
                            request.Idade, request.Peso, request.Sexo,
                            request.Observacoes, request.DonoId);

        await _repository.AdicionarAsync(pet, ct);
        await _unitOfWork.CommitAsync(ct);
        return _mapper.Map<PetResponse>(pet);
    }
}
