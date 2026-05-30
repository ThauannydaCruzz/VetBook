using AutoMapper;
using VetBook.CadastroContext.Application.DTOs;
using VetBook.CadastroContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.CadastroContext.Application.UseCases.Pets;

// Use Case responsável por buscar um pet pelo seu ID único.
// Lança NotFoundException se o pet não existir.
public class ObterPetUseCase
{
    private readonly IPetRepository _repository;
    private readonly IMapper _mapper;

    public ObterPetUseCase(IPetRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper     = mapper;
    }

    public async Task<PetResponse> ExecuteAsync(Guid id, CancellationToken ct = default)
    {
        var pet = await _repository.ObterPorIdAsync(id, ct)
            ?? throw new NotFoundException("Pet", id);
        return _mapper.Map<PetResponse>(pet);
    }
}
