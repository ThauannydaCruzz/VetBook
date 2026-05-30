using AutoMapper;
using VetBook.AgendamentoContext.Application.DTOs;
using VetBook.AgendamentoContext.Domain.Interfaces;

namespace VetBook.AgendamentoContext.Application.UseCases;

// Use Case responsável por retornar todas as consultas de um pet específico.
// Usado na tela de histórico de consultas do pet no frontend.
public class ObterConsultasPorPetUseCase
{
    private readonly IConsultaRepository _repository;
    private readonly IMapper _mapper;

    public ObterConsultasPorPetUseCase(IConsultaRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper     = mapper;
    }

    // Retorna lista de todas as consultas associadas ao petId informado
    public async Task<IEnumerable<ConsultaResponse>> ExecuteAsync(Guid petId, CancellationToken ct = default)
    {
        var consultas = await _repository.ObterPorPetAsync(petId, ct);
        return _mapper.Map<IEnumerable<ConsultaResponse>>(consultas);
    }
}
