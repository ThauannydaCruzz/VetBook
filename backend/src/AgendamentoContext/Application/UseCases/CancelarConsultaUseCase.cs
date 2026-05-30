using AutoMapper;
using VetBook.AgendamentoContext.Application.DTOs;
using VetBook.AgendamentoContext.Application.Interfaces;
using VetBook.AgendamentoContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.AgendamentoContext.Application.UseCases;

// Use Case responsável por cancelar uma consulta existente.
// Busca a consulta, delega o cancelamento à entidade de domínio e persiste.
public class CancelarConsultaUseCase
{
    private readonly IConsultaRepository _repository;
    private readonly IAgendamentoUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public CancelarConsultaUseCase(IConsultaRepository repository, IAgendamentoUnitOfWork unitOfWork, IMapper mapper)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
        _mapper     = mapper;
    }

    public async Task<ConsultaResponse> ExecuteAsync(Guid id, CancelarConsultaRequest request, CancellationToken ct = default)
    {
        // Busca a consulta — lança NotFoundException se não existir
        var consulta = await _repository.ObterPorIdAsync(id, ct)
            ?? throw new NotFoundException("Consulta", id);

        // A entidade valida se o status permite cancelamento (regra de domínio)
        consulta.Cancelar(request.MotivoCancelamento);

        // Marca como atualizada no repositório e salva via Unit of Work
        _repository.Atualizar(consulta);
        await _unitOfWork.CommitAsync(ct);

        // Retorna o DTO atualizado com o novo status "Cancelada"
        return _mapper.Map<ConsultaResponse>(consulta);
    }
}
