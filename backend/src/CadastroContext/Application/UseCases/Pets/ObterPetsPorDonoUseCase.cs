using AutoMapper;
using VetBook.CadastroContext.Application.DTOs;
using VetBook.CadastroContext.Domain.Interfaces;

namespace VetBook.CadastroContext.Application.UseCases.Pets;

// Use Case responsável por retornar todos os pets de um dono específico.
// Usado na tela "Meus Pets" do frontend para listar os animais do usuário logado.
public class ObterPetsPorDonoUseCase
{
    private readonly IPetRepository _repository;
    private readonly IMapper _mapper;

    public ObterPetsPorDonoUseCase(IPetRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper     = mapper;
    }

    // Retorna todos os pets do dono sem paginação — adequado para listas pequenas
    public async Task<IEnumerable<PetResponse>> ExecuteAsync(Guid donoId, CancellationToken ct = default)
    {
        var pets = await _repository.ObterPorDonoAsync(donoId, ct);
        return _mapper.Map<IEnumerable<PetResponse>>(pets);
    }
}
