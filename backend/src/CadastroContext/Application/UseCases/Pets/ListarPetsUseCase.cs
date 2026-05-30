using AutoMapper;
using VetBook.CadastroContext.Application.DTOs;
using VetBook.CadastroContext.Domain.Interfaces;
using VetBook.SharedKernel.Common;

namespace VetBook.CadastroContext.Application.UseCases.Pets;

// Use Case responsável por listar pets com filtros e paginação.
// Suporta filtro por nome, espécie, raça e donoId.
public class ListarPetsUseCase
{
    private readonly IPetRepository _repository;
    private readonly IMapper _mapper;

    public ListarPetsUseCase(IPetRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper     = mapper;
    }

    public async Task<PagedResult<PetResponse>> ExecuteAsync(PetFiltro filtro, CancellationToken ct = default)
    {
        // Busca pets paginados respeitando os filtros do PetFiltro
        var result = await _repository.ListarAsync(filtro, ct);

        // Monta resultado paginado convertendo entidades para DTOs
        return PagedResult<PetResponse>.Create(
            _mapper.Map<IEnumerable<PetResponse>>(result.Items),
            result.TotalItems, filtro.Page, filtro.PageSize);
    }
}
