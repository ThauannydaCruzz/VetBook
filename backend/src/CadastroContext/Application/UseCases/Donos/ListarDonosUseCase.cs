using AutoMapper;
using VetBook.CadastroContext.Application.DTOs;
using VetBook.CadastroContext.Domain.Interfaces;
using VetBook.SharedKernel.Common;

namespace VetBook.CadastroContext.Application.UseCases.Donos;

// Use Case responsável por listar donos com filtros e paginação.
// Usado no painel administrativo para gerenciar tutores.
public class ListarDonosUseCase
{
    private readonly IDonoRepository _repository;
    private readonly IMapper _mapper;

    public ListarDonosUseCase(IDonoRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper     = mapper;
    }

    public async Task<PagedResult<DonoResponse>> ExecuteAsync(DonoFiltro filtro, CancellationToken ct = default)
    {
        // Busca os donos paginados com os filtros aplicados (nome, CPF, email)
        var result = await _repository.ListarAsync(filtro, ct);

        // Monta o resultado paginado mapeando entidades para DTOs
        return PagedResult<DonoResponse>.Create(
            _mapper.Map<IEnumerable<DonoResponse>>(result.Items),
            result.TotalItems, filtro.Page, filtro.PageSize);
    }
}
