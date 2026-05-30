using AutoMapper;
using VetBook.CadastroContext.Application.DTOs;
using VetBook.CadastroContext.Application.Interfaces;
using VetBook.CadastroContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.CadastroContext.Application.UseCases.Pets;

// Use Case responsável por atualizar os dados de um pet existente.
// Permite alterar nome, espécie, raça, idade, peso, sexo e observações.
// O DonoId não é alterável — pet pertence ao mesmo dono para sempre.
public class AtualizarPetUseCase
{
    private readonly IPetRepository _repository;
    private readonly ICadastroUnitOfWork _unitOfWork;
    private readonly IMapper _mapper;

    public AtualizarPetUseCase(IPetRepository repository, ICadastroUnitOfWork unitOfWork, IMapper mapper)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
        _mapper     = mapper;
    }

    public async Task<PetResponse> ExecuteAsync(Guid id, UpdatePetRequest request, CancellationToken ct = default)
    {
        // Lança NotFoundException se o pet não existir no banco
        var pet = await _repository.ObterPorIdAsync(id, ct)
            ?? throw new NotFoundException("Pet", id);

        // A entidade encapsula a lógica de atualização e atualiza DataAtualizacao
        pet.Atualizar(request.Nome, request.Especie, request.Raca,
                      request.Idade, request.Peso, request.Sexo, request.Observacoes);
        _repository.Atualizar(pet);
        await _unitOfWork.CommitAsync(ct);
        return _mapper.Map<PetResponse>(pet);
    }
}
