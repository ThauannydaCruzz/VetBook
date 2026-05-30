using AutoMapper;
using VetBook.AgendamentoContext.Application.DTOs;
using VetBook.AgendamentoContext.Application.Interfaces;
using VetBook.AgendamentoContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.AgendamentoContext.Application.UseCases;

// Use Case responsável por finalizar uma consulta após o atendimento.
// Transição de status: Confirmada → Finalizada.
// Permite registrar observações finais do atendimento.
public class FinalizarConsultaUseCase
{
    private readonly IConsultaRepository _repository;
    private readonly IAgendamentoUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public FinalizarConsultaUseCase(IConsultaRepository repository, IAgendamentoUnitOfWork unitOfWork, IMapper mapper)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
        _mapper     = mapper;
    }

    public async Task<ConsultaResponse> ExecuteAsync(Guid id, FinalizarConsultaRequest request, CancellationToken ct = default)
    {
        // Lança NotFoundException se a consulta não existir no banco
        var consulta = await _repository.ObterPorIdAsync(id, ct)
            ?? throw new NotFoundException("Consulta", id);

        // A entidade valida a transição de estado e registra as observações finais
        consulta.Finalizar(request.Observacoes);
        _repository.Atualizar(consulta);
        await _unitOfWork.CommitAsync(ct);
        return _mapper.Map<ConsultaResponse>(consulta);
    }
}
