using VetBook.CadastroContext.Application.DTOs;
using VetBook.CadastroContext.Application.Interfaces;
using VetBook.CadastroContext.Application.UseCases.Donos;
using VetBook.CadastroContext.Domain.Interfaces;
using VetBook.SharedKernel.Common;

namespace VetBook.CadastroContext.Application.Services;

/* Serviço de donos — atua como fachada (Facade Pattern).
 * Cada operação é delegada ao Use Case especializado correspondente.
 * Isso mantém a lógica de negócio isolada e facilita testes unitários. */
public class DonoService : IDonoService
{
    private readonly CriarDonoUseCase              _criar;
    private readonly ValidarCredenciaisDonoUseCase _validarCredenciais;
    private readonly AtualizarDonoUseCase          _atualizar;
    private readonly RemoverDonoUseCase            _remover;
    private readonly ObterDonoUseCase              _obter;
    private readonly ListarDonosUseCase            _listar;

    public DonoService(
        CriarDonoUseCase              criar,
        ValidarCredenciaisDonoUseCase validarCredenciais,
        AtualizarDonoUseCase          atualizar,
        RemoverDonoUseCase            remover,
        ObterDonoUseCase              obter,
        ListarDonosUseCase            listar)
    {
        _criar              = criar;
        _validarCredenciais = validarCredenciais;
        _atualizar          = atualizar;
        _remover            = remover;
        _obter              = obter;
        _listar             = listar;
    }

    // Cada método abaixo delega diretamente ao Use Case correspondente
    public Task<DonoResponse>              CriarAsync(CreateDonoRequest request, CancellationToken ct = default)
        => _criar.ExecuteAsync(request, ct);

    // Usado no login do dono — verifica CPF e senha hasheada
    public Task<DonoResponse?>             ValidarCredenciaisAsync(string cpf, string senha, CancellationToken ct = default)
        => _validarCredenciais.ExecuteAsync(cpf, senha, ct);

    public Task<DonoResponse>              AtualizarAsync(Guid id, UpdateDonoRequest request, CancellationToken ct = default)
        => _atualizar.ExecuteAsync(id, request, ct);

    public Task                            RemoverAsync(Guid id, CancellationToken ct = default)
        => _remover.ExecuteAsync(id, ct);

    public Task<DonoResponse>              ObterPorIdAsync(Guid id, CancellationToken ct = default)
        => _obter.ExecuteAsync(id, ct);

    public Task<PagedResult<DonoResponse>> ListarAsync(DonoFiltro filtro, CancellationToken ct = default)
        => _listar.ExecuteAsync(filtro, ct);
}
