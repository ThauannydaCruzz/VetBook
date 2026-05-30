using AutoMapper;
using VetBook.AgendamentoContext.Application.DTOs;
using VetBook.AgendamentoContext.Application.Interfaces;
using VetBook.AgendamentoContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.AgendamentoContext.Application.UseCases;

// Use Case responsável por reagendar uma consulta para nova data/hora.
// Antes de reagendar, verifica conflitos de horário tanto para o veterinário
// quanto para o pet — garantindo que nenhum dos dois tenha outra consulta no mesmo horário.
public class ReagendarConsultaUseCase
{
    private readonly IConsultaRepository _repository;
    private readonly IAgendamentoUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public ReagendarConsultaUseCase(IConsultaRepository repository, IAgendamentoUnitOfWork unitOfWork, IMapper mapper)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
        _mapper     = mapper;
    }

    public async Task<ConsultaResponse> ExecuteAsync(Guid id, UpdateConsultaRequest request, CancellationToken ct = default)
    {
        // Busca a consulta existente — lança NotFoundException se não encontrar
        var consulta = await _repository.ObterPorIdAsync(id, ct)
            ?? throw new NotFoundException("Consulta", id);

        // Verifica se o veterinário já tem outra consulta no mesmo horário
        // O parâmetro "ignorarId = id" exclui a própria consulta da verificação
        if (await _repository.ExisteConflitoPorVeterinarioAsync(consulta.VeterinarioId, request.DataConsulta, id, ct))
            throw new DomainException("O veterinario ja possui uma consulta agendada neste horario.");

        // Verifica se o pet já tem outra consulta no mesmo horário
        if (await _repository.ExisteConflitoPorPetAsync(consulta.PetId, request.DataConsulta, id, ct))
            throw new DomainException("O pet ja possui uma consulta agendada neste horario.");

        // Delega o reagendamento à entidade de domínio e persiste as mudanças
        consulta.Reagendar(request.DataConsulta, request.MotivoConsulta);
        _repository.Atualizar(consulta);
        await _unitOfWork.CommitAsync(ct);
        return _mapper.Map<ConsultaResponse>(consulta);
    }
}
