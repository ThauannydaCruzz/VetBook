using VetBook.AgendamentoContext.Application.DTOs;
using VetBook.AgendamentoContext.Application.Interfaces;
using VetBook.AgendamentoContext.Application.UseCases;
using VetBook.AgendamentoContext.Domain.Interfaces;
using VetBook.SharedKernel.Common;

namespace VetBook.AgendamentoContext.Application.Services;

/* Serviço de consultas — funciona como fachada (Facade Pattern).
 * Recebe todos os Use Cases via injeção de dependência e delega cada
 * operação para o Use Case responsável. Implementa IConsultaService
 * que é consumido pelos Controllers da API. */
public class ConsultaService : IConsultaService
{
    // Cada campo armazena o Use Case responsável por uma operação específica
    private readonly AgendarConsultaUseCase              _agendar;
    private readonly ReagendarConsultaUseCase            _reagendar;
    private readonly ConfirmarConsultaUseCase            _confirmar;
    private readonly CancelarConsultaUseCase             _cancelar;
    private readonly FinalizarConsultaUseCase            _finalizar;
    private readonly ObterConsultaUseCase                _obter;
    private readonly ListarConsultasUseCase              _listar;
    private readonly ObterConsultasPorPetUseCase         _porPet;
    private readonly ObterConsultasPorVeterinarioUseCase _porVet;

    // Todos os Use Cases são injetados pelo contêiner de DI
    public ConsultaService(
        AgendarConsultaUseCase              agendar,
        ReagendarConsultaUseCase            reagendar,
        ConfirmarConsultaUseCase            confirmar,
        CancelarConsultaUseCase             cancelar,
        FinalizarConsultaUseCase            finalizar,
        ObterConsultaUseCase                obter,
        ListarConsultasUseCase              listar,
        ObterConsultasPorPetUseCase         porPet,
        ObterConsultasPorVeterinarioUseCase porVet)
    {
        _agendar   = agendar;
        _reagendar = reagendar;
        _confirmar = confirmar;
        _cancelar  = cancelar;
        _finalizar = finalizar;
        _obter     = obter;
        _listar    = listar;
        _porPet    = porPet;
        _porVet    = porVet;
    }

    // Cada método simplesmente delega a execução ao Use Case correspondente
    public Task<ConsultaResponse>              AgendarAsync(CreateConsultaRequest request, CancellationToken ct = default)
        => _agendar.ExecuteAsync(request, ct);

    public Task<ConsultaResponse>              ReagendarAsync(Guid id, UpdateConsultaRequest request, CancellationToken ct = default)
        => _reagendar.ExecuteAsync(id, request, ct);

    public Task<ConsultaResponse>              ConfirmarAsync(Guid id, CancellationToken ct = default)
        => _confirmar.ExecuteAsync(id, ct);

    public Task<ConsultaResponse>              CancelarAsync(Guid id, CancelarConsultaRequest request, CancellationToken ct = default)
        => _cancelar.ExecuteAsync(id, request, ct);

    public Task<ConsultaResponse>              FinalizarAsync(Guid id, FinalizarConsultaRequest request, CancellationToken ct = default)
        => _finalizar.ExecuteAsync(id, request, ct);

    public Task<ConsultaResponse>              ObterPorIdAsync(Guid id, CancellationToken ct = default)
        => _obter.ExecuteAsync(id, ct);

    public Task<PagedResult<ConsultaResponse>> ListarAsync(ConsultaFiltro filtro, CancellationToken ct = default)
        => _listar.ExecuteAsync(filtro, ct);

    public Task<IEnumerable<ConsultaResponse>> ObterPorPetAsync(Guid petId, CancellationToken ct = default)
        => _porPet.ExecuteAsync(petId, ct);

    public Task<IEnumerable<ConsultaResponse>> ObterPorVeterinarioAsync(Guid veterinarioId, CancellationToken ct = default)
        => _porVet.ExecuteAsync(veterinarioId, ct);
}
