using AutoMapper;
using VetBook.AgendamentoContext.Application.DTOs;
using VetBook.AgendamentoContext.Application.Interfaces;
using VetBook.AgendamentoContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.AgendamentoContext.Application.UseCases;

// Use Case responsável por confirmar uma consulta agendada.
// Transição de status: Agendada → Confirmada.
// A validação da transição de estado é responsabilidade da entidade Consulta.
public class ConfirmarConsultaUseCase
{
    private readonly IConsultaRepository _repository;
    private readonly IAgendamentoUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public ConfirmarConsultaUseCase(IConsultaRepository repository, IAgendamentoUnitOfWork unitOfWork, IMapper mapper)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
        _mapper     = mapper;
    }

    public async Task<ConsultaResponse> ExecuteAsync(Guid id, CancellationToken ct = default)
    {
        // Lança exceção se a consulta não for encontrada
        var consulta = await _repository.ObterPorIdAsync(id, ct)
            ?? throw new NotFoundException("Consulta", id);

        // A entidade aplica a regra de negócio (só pode confirmar se estiver Agendada)
        consulta.Confirmar();
        _repository.Atualizar(consulta);
        await _unitOfWork.CommitAsync(ct);
        return _mapper.Map<ConsultaResponse>(consulta);
    }
}
