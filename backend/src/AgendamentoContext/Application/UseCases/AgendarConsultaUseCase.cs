using AutoMapper;
using VetBook.AgendamentoContext.Application.DTOs;
using VetBook.AgendamentoContext.Application.Interfaces;
using VetBook.AgendamentoContext.Domain.Entities;
using VetBook.AgendamentoContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.AgendamentoContext.Application.UseCases;

/* Use Case responsável por agendar uma nova consulta veterinária.
 * Antes de criar o agendamento, verifica duas regras importantes:
 * 1. O veterinário não pode ter outra consulta no mesmo horário (±60min)
 * 2. O pet não pode ter outra consulta no mesmo horário (±60min) */
public class AgendarConsultaUseCase
{
    // Repositório de consultas — usado para verificar conflitos e salvar o agendamento
    private readonly IConsultaRepository _repository;

    // Unit of Work — commita a transação no banco após salvar
    private readonly IAgendamentoUnitOfWork _unitOfWork;

    // AutoMapper — converte a entidade Consulta em ConsultaResponse para retornar ao controller
    private readonly IMapper _mapper;

    public AgendarConsultaUseCase(IConsultaRepository repository, IAgendamentoUnitOfWork unitOfWork, IMapper mapper)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
        _mapper     = mapper;
    }

    // Executa o agendamento — valida conflitos, cria a entidade e salva no banco
    public async Task<ConsultaResponse> ExecuteAsync(CreateConsultaRequest request, CancellationToken ct = default)
    {
        // Verificação 1: o veterinário já tem consulta nesse horário?
        if (await _repository.ExisteConflitoPorVeterinarioAsync(request.VeterinarioId, request.DataConsulta, null, ct))
            throw new DomainException("O veterinario ja possui uma consulta agendada neste horario.");

        // Verificação 2: o pet já tem consulta nesse horário?
        if (await _repository.ExisteConflitoPorPetAsync(request.PetId, request.DataConsulta, null, ct))
            throw new DomainException("O pet ja possui uma consulta agendada neste horario.");

        // Cria a entidade Consulta pelo método fábrica (que já valida data futura, motivo, etc.)
        var consulta = Consulta.Criar(request.PetId, request.VeterinarioId,
                                      request.DataConsulta, request.MotivoConsulta, request.Observacoes);

        // Salva no banco e commita
        await _repository.AdicionarAsync(consulta, ct);
        await _unitOfWork.CommitAsync(ct);

        // Retorna o DTO da consulta criada
        return _mapper.Map<ConsultaResponse>(consulta);
    }
}
