using AutoMapper;
using VetBook.VeterinarioContext.Application.DTOs;
using VetBook.VeterinarioContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.VeterinarioContext.Application.UseCases;

// Use Case responsável por buscar um veterinário pelo ID.
// Lança NotFoundException se o veterinário não existir.
public class ObterVeterinarioUseCase
{
    private readonly IVeterinarioRepository _repository;
    private readonly IMapper _mapper;

    public ObterVeterinarioUseCase(IVeterinarioRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper     = mapper;
    }

    public async Task<VeterinarioResponse> ExecuteAsync(Guid id, CancellationToken ct = default)
    {
        var vet = await _repository.ObterPorIdAsync(id, ct)
            ?? throw new NotFoundException("Veterinario", id);
        return _mapper.Map<VeterinarioResponse>(vet);
    }
}
