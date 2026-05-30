using AutoMapper;
using VetBook.VeterinarioContext.Application.DTOs;
using VetBook.VeterinarioContext.Domain.Interfaces;

namespace VetBook.VeterinarioContext.Application.UseCases;

// Use Case responsável por listar apenas as clínicas ativas.
// Usado no agendamento para apresentar somente opções disponíveis ao usuário.
public class ListarClinicasAtivasUseCase
{
    private readonly IClinicaRepository _repo;
    private readonly IMapper _mapper;

    public ListarClinicasAtivasUseCase(IClinicaRepository repo, IMapper mapper)
    {
        _repo = repo; _mapper = mapper;
    }

    // Retorna lista (não paginada) de clínicas ativas ordenadas por nome
    public async Task<List<ClinicaResponse>> ExecutarAsync(CancellationToken ct)
    {
        var clinicas = await _repo.ListarAtivasAsync(ct);
        return clinicas.Select(c => _mapper.Map<ClinicaResponse>(c)).ToList();
    }
}
