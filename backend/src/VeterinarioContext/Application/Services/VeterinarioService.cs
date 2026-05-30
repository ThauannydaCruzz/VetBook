using VetBook.VeterinarioContext.Application.DTOs;
using VetBook.VeterinarioContext.Application.Interfaces;
using VetBook.VeterinarioContext.Application.UseCases;
using VetBook.VeterinarioContext.Domain.Interfaces;
using VetBook.SharedKernel.Common;

namespace VetBook.VeterinarioContext.Application.Services;

/* Serviço de veterinários — fachada que delega operações para Use Cases.
 * Implementa IVeterinarioService consumido pelos Controllers da API. */
public class VeterinarioService : IVeterinarioService
{
    // Um campo por Use Case — injeção de dependência via construtor
    private readonly CriarVeterinarioUseCase         _criar;
    private readonly AtualizarVeterinarioUseCase     _atualizar;
    private readonly AtivarVeterinarioUseCase        _ativar;
    private readonly InativarVeterinarioUseCase      _inativar;
    private readonly RemoverVeterinarioUseCase       _remover;
    private readonly ObterVeterinarioUseCase         _obter;
    private readonly ListarVeterinariosUseCase       _listar;
    private readonly ListarVeterinariosAtivosUseCase _listarAtivos;

    public VeterinarioService(
        CriarVeterinarioUseCase         criar,
        AtualizarVeterinarioUseCase     atualizar,
        AtivarVeterinarioUseCase        ativar,
        InativarVeterinarioUseCase      inativar,
        RemoverVeterinarioUseCase       remover,
        ObterVeterinarioUseCase         obter,
        ListarVeterinariosUseCase       listar,
        ListarVeterinariosAtivosUseCase listarAtivos)
    {
        _criar        = criar;
        _atualizar    = atualizar;
        _ativar       = ativar;
        _inativar     = inativar;
        _remover      = remover;
        _obter        = obter;
        _listar       = listar;
        _listarAtivos = listarAtivos;
    }

    // Cada método delega diretamente ao Use Case correspondente
    public Task<VeterinarioResponse>              CriarAsync(CreateVeterinarioRequest request, CancellationToken ct = default)
        => _criar.ExecuteAsync(request, ct);

    public Task<VeterinarioResponse>              AtualizarAsync(Guid id, UpdateVeterinarioRequest request, CancellationToken ct = default)
        => _atualizar.ExecuteAsync(id, request, ct);

    // Ativar e Inativar não retornam dados — apenas alteram o flag Ativo
    public Task                                   AtivarAsync(Guid id, CancellationToken ct = default)
        => _ativar.ExecuteAsync(id, ct);

    public Task                                   InativarAsync(Guid id, CancellationToken ct = default)
        => _inativar.ExecuteAsync(id, ct);

    public Task                                   RemoverAsync(Guid id, CancellationToken ct = default)
        => _remover.ExecuteAsync(id, ct);

    public Task<VeterinarioResponse>              ObterPorIdAsync(Guid id, CancellationToken ct = default)
        => _obter.ExecuteAsync(id, ct);

    public Task<PagedResult<VeterinarioResponse>> ListarAsync(VeterinarioFiltro filtro, CancellationToken ct = default)
        => _listar.ExecuteAsync(filtro, ct);

    // Usado no agendamento para mostrar apenas veterinários disponíveis
    public Task<IEnumerable<VeterinarioResponse>> ListarAtivosAsync(CancellationToken ct = default)
        => _listarAtivos.ExecuteAsync(ct);
}
