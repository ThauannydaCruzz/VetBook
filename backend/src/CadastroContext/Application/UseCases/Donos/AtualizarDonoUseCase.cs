using AutoMapper;
using VetBook.CadastroContext.Application.DTOs;
using VetBook.CadastroContext.Application.Interfaces;
using VetBook.CadastroContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.CadastroContext.Application.UseCases.Donos;

// Use Case responsável por atualizar os dados de um dono existente.
// Não permite alterar CPF (imutável) ou senha (operação separada).
public class AtualizarDonoUseCase
{
    private readonly IDonoRepository _repository;
    private readonly ICadastroUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public AtualizarDonoUseCase(IDonoRepository repository, ICadastroUnitOfWork unitOfWork, IMapper mapper)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
        _mapper     = mapper;
    }

    public async Task<DonoResponse> ExecuteAsync(Guid id, UpdateDonoRequest request, CancellationToken ct = default)
    {
        // Lança NotFoundException se o dono não existir no banco
        var dono = await _repository.ObterPorIdAsync(id, ct)
            ?? throw new NotFoundException("Dono", id);

        // A entidade encapsula a lógica de atualização e registra DataAtualizacao
        dono.Atualizar(request.Nome, request.Email, request.Telefone, request.Endereco);
        _repository.Atualizar(dono);
        await _unitOfWork.CommitAsync(ct);
        return _mapper.Map<DonoResponse>(dono);
    }
}
