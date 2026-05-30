using AutoMapper;
using VetBook.AgendamentoContext.Application.DTOs;
using VetBook.AgendamentoContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.AgendamentoContext.Application.UseCases;

// Use Case responsável por buscar uma consulta pelo seu ID único.
// Lança NotFoundException se a consulta não existir.
public class ObterConsultaUseCase
{
    private readonly IConsultaRepository _repository;
    private readonly IMapper _mapper;

    public ObterConsultaUseCase(IConsultaRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper     = mapper;
    }

    public async Task<ConsultaResponse> ExecuteAsync(Guid id, CancellationToken ct = default)
    {
        // Lança NotFoundException com mensagem amigável se não encontrar
        var consulta = await _repository.ObterPorIdAsync(id, ct)
            ?? throw new NotFoundException("Consulta", id);
        return _mapper.Map<ConsultaResponse>(consulta);
    }
}
