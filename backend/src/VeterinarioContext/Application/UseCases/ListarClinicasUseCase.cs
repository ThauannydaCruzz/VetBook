using AutoMapper;
using VetBook.SharedKernel.Common;
using VetBook.VeterinarioContext.Application.DTOs;
using VetBook.VeterinarioContext.Domain.Interfaces;

namespace VetBook.VeterinarioContext.Application.UseCases;

// Use Case responsável por listar todas as clínicas com paginação e busca.
// Usado no painel administrativo para gerenciar clínicas.
public class ListarClinicasUseCase
{
    private readonly IClinicaRepository _repo;
    private readonly IMapper _mapper;

    public ListarClinicasUseCase(IClinicaRepository repo, IMapper mapper)
    {
        _repo = repo; _mapper = mapper;
    }

    // Permite buscar por nome ou endereço via parâmetro "busca"
    public async Task<PagedResult<ClinicaResponse>> ExecutarAsync(
        int page, int pageSize, string? busca, CancellationToken ct)
    {
        var result = await _repo.ListarAsync(page, pageSize, busca, ct);
        var mapped = result.Items.Select(c => _mapper.Map<ClinicaResponse>(c)).ToList();
        return PagedResult<ClinicaResponse>.Create(mapped, result.TotalItems, page, pageSize);
    }
}
