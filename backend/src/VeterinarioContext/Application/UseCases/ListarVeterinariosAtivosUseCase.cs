using AutoMapper;
using VetBook.VeterinarioContext.Application.DTOs;
using VetBook.VeterinarioContext.Domain.Interfaces;

namespace VetBook.VeterinarioContext.Application.UseCases;

// Use Case responsável por listar todos os veterinários ativos.
// Usado no agendamento para exibir apenas profissionais disponíveis.
public class ListarVeterinariosAtivosUseCase
{
    private readonly IVeterinarioRepository _repository;
    private readonly IMapper _mapper;

    public ListarVeterinariosAtivosUseCase(IVeterinarioRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper     = mapper;
    }

    // Retorna lista sem paginação — adequado para dropdown no agendamento
    public async Task<IEnumerable<VeterinarioResponse>> ExecuteAsync(CancellationToken ct = default)
    {
        var vets = await _repository.ListarAtivosAsync(ct);
        return _mapper.Map<IEnumerable<VeterinarioResponse>>(vets);
    }
}
