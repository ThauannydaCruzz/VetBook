using AutoMapper;
using VetBook.CadastroContext.Application.DTOs;
using VetBook.CadastroContext.Application.Interfaces;
using VetBook.CadastroContext.Domain.Entities;
using VetBook.CadastroContext.Domain.Interfaces;
using VetBook.SharedKernel.Exceptions;

namespace VetBook.CadastroContext.Application.UseCases.Donos;

/* Use Case responsável por cadastrar um novo dono no sistema.
 * Segue o padrão Clean Architecture: cada ação de negócio tem sua própria classe.
 * Passos: verifica se CPF já existe → gera hash da senha → cria entidade → salva no banco. */
public class CriarDonoUseCase
{
    // Repositório usado para verificar duplicatas e salvar o novo dono
    private readonly IDonoRepository _repository;

    // Unit of Work — usado para commitar a transação no banco após todas as operações
    private readonly ICadastroUnitOfWork _unitOfWork;

    // AutoMapper — converte a entidade Dono em DonoResponse para retornar ao controller
    private readonly IMapper _mapper;

    public CriarDonoUseCase(IDonoRepository repository, ICadastroUnitOfWork unitOfWork, IMapper mapper)
    {
        _repository = repository;
        _unitOfWork = unitOfWork;
        _mapper     = mapper;
    }

    // Executa o cadastro do dono com todas as validações de negócio
    public async Task<DonoResponse> ExecuteAsync(CreateDonoRequest request, CancellationToken ct = default)
    {
        // Verifica se o CPF já está cadastrado — não é possível ter dois donos com o mesmo CPF
        if (await _repository.CpfExisteAsync(request.Cpf, null, ct))
            throw new DomainException($"CPF {request.Cpf} ja esta cadastrado.");

        // Gera o hash da senha usando BCrypt — nunca salvamos a senha em texto puro
        var senhaHash = BCrypt.Net.BCrypt.HashPassword(request.Senha);

        // Cria a entidade Dono pelo método fábrica, que valida todos os campos internamente
        var dono = Dono.Criar(request.Nome, request.Cpf, request.Email,
                              request.Telefone, request.Endereco, senhaHash);

        // Adiciona ao repositório e commita a transação — isso gera o INSERT no banco
        await _repository.AdicionarAsync(dono, ct);
        await _unitOfWork.CommitAsync(ct);

        // Converte a entidade para o DTO de resposta e retorna ao controller
        return _mapper.Map<DonoResponse>(dono);
    }
}
