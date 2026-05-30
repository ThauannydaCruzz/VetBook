using AutoMapper;
using VetBook.AgendamentoContext.Application.DTOs;
using VetBook.AgendamentoContext.Domain.Interfaces;

namespace VetBook.AgendamentoContext.Application.UseCases;

// Use Case responsável por retornar todas as consultas de um veterinário.
// Usado pela tela de agenda do veterinário no painel administrativo.
public class ObterConsultasPorVeterinarioUseCase
{
    private readonly IConsultaRepository _repository;
    private readonly IMapper _mapper;

    public ObterConsultasPorVeterinarioUseCase(IConsultaRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper     = mapper;
    }

    // Retorna todas as consultas do veterinário identificado pelo veterinarioId
    public async Task<IEnumerable<ConsultaResponse>> ExecuteAsync(Guid veterinarioId, CancellationToken ct = default)
    {
        var consultas = await _repository.ObterPorVeterinarioAsync(veterinarioId, ct);
        return _mapper.Map<IEnumerable<ConsultaResponse>>(consultas);
    }
}
