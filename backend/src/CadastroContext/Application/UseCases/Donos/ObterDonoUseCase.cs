using AutoMapper;
using VetBook.CadastroContext.Application.DTOs;
using VetBook.CadastroContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.CadastroContext.Application.UseCases.Donos;

// Use Case responsável por buscar um dono pelo ID incluindo seus pets.
// Usa ObterComPetsAsync para carregar a coleção de pets em uma única query (eager loading).
public class ObterDonoUseCase
{
    private readonly IDonoRepository _repository;
    private readonly IMapper _mapper;

    public ObterDonoUseCase(IDonoRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper     = mapper;
    }

    public async Task<DonoResponse> ExecuteAsync(Guid id, CancellationToken ct = default)
    {
        // Busca com Include dos pets — lança NotFoundException se não encontrar
        var dono = await _repository.ObterComPetsAsync(id, ct)
            ?? throw new NotFoundException("Dono", id);
        return _mapper.Map<DonoResponse>(dono);
    }
}
