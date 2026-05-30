using AutoMapper;
using VetBook.SharedKernel.Common;
using VetBook.VeterinarioContext.Application.DTOs;
using VetBook.VeterinarioContext.Domain.Interfaces;

namespace VetBook.VeterinarioContext.Application.UseCases;

// Use Case responsável por listar todos os veterinários com paginação e filtros.
// Usado no painel administrativo para gerenciar a equipe de veterinários.
public class ListarVeterinariosUseCase
{
    private readonly IVeterinarioRepository _repository;
    private readonly IMapper _mapper;

    public ListarVeterinariosUseCase(IVeterinarioRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper     = mapper;
    }

    // Suporta filtro por nome, CRMV, especialidade e status ativo/inativo
    public async Task<PagedResult<VeterinarioResponse>> ExecuteAsync(
        VeterinarioFiltro filtro, CancellationToken ct = default)
    {
        var result = await _repository.ListarAsync(filtro, ct);
        var mapped = result.Items.Select(v => _mapper.Map<VeterinarioResponse>(v)).ToList();
        return PagedResult<VeterinarioResponse>.Create(mapped, result.TotalItems, filtro.Page, filtro.PageSize);
    }
}
