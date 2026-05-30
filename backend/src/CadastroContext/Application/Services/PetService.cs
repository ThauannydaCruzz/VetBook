using VetBook.CadastroContext.Application.DTOs;
using VetBook.CadastroContext.Application.Interfaces;
using VetBook.CadastroContext.Application.UseCases.Pets;
using VetBook.CadastroContext.Domain.Interfaces;
using VetBook.SharedKernel.Common;

namespace VetBook.CadastroContext.Application.Services;

/* Serviço de pets — fachada que delega operações para Use Cases especializados.
 * Implementa IPetService consumido pelos Controllers da API. */
public class PetService : IPetService
{
    private readonly CriarPetUseCase           _criar;
    private readonly AtualizarPetUseCase       _atualizar;
    private readonly RemoverPetUseCase         _remover;
    private readonly ObterPetUseCase           _obter;
    private readonly ListarPetsUseCase         _listar;
    private readonly ObterPetsPorDonoUseCase   _porDono;

    public PetService(
        CriarPetUseCase         criar,
        AtualizarPetUseCase     atualizar,
        RemoverPetUseCase       remover,
        ObterPetUseCase         obter,
        ListarPetsUseCase       listar,
        ObterPetsPorDonoUseCase porDono)
    {
        _criar     = criar;
        _atualizar = atualizar;
        _remover   = remover;
        _obter     = obter;
        _listar    = listar;
        _porDono   = porDono;
    }

    public Task<PetResponse>              CriarAsync(CreatePetRequest request, CancellationToken ct = default)
        => _criar.ExecuteAsync(request, ct);

    public Task<PetResponse>              AtualizarAsync(Guid id, UpdatePetRequest request, CancellationToken ct = default)
        => _atualizar.ExecuteAsync(id, request, ct);

    public Task                           RemoverAsync(Guid id, CancellationToken ct = default)
        => _remover.ExecuteAsync(id, ct);

    public Task<PetResponse>              ObterPorIdAsync(Guid id, CancellationToken ct = default)
        => _obter.ExecuteAsync(id, ct);

    public Task<PagedResult<PetResponse>> ListarAsync(PetFiltro filtro, CancellationToken ct = default)
        => _listar.ExecuteAsync(filtro, ct);

    // Busca todos os pets de um dono sem paginação — usado na tela "Meus Pets"
    public Task<IEnumerable<PetResponse>> ObterPorDonoAsync(Guid donoId, CancellationToken ct = default)
        => _porDono.ExecuteAsync(donoId, ct);
}
