using AutoMapper;
using VetBook.AgendamentoContext.Application.DTOs;
using VetBook.AgendamentoContext.Domain.Interfaces;
using VetBook.SharedKernel.Common;

namespace VetBook.AgendamentoContext.Application.UseCases;

// Use Case responsável por listar consultas com filtro e paginação.
// Suporta filtro por pet, veterinário, dono, status e intervalo de datas.
public class ListarConsultasUseCase
{
    private readonly IConsultaRepository _repository;
    private readonly IMapper _mapper;

    public ListarConsultasUseCase(IConsultaRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper     = mapper;
    }

    public async Task<PagedResult<ConsultaResponse>> ExecuteAsync(ConsultaFiltro filtro, CancellationToken ct = default)
    {
        // Busca as consultas paginadas do repositório com os filtros aplicados
        var result = await _repository.ListarAsync(filtro, ct);

        // Cria o resultado paginado mapeando as entidades para DTOs de resposta
        return PagedResult<ConsultaResponse>.Create(
            _mapper.Map<IEnumerable<ConsultaResponse>>(result.Items),
            result.TotalItems, filtro.Page, filtro.PageSize);
    }
}
