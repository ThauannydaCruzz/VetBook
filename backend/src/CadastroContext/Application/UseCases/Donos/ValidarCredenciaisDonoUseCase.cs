using AutoMapper;
using VetBook.CadastroContext.Application.DTOs;
using VetBook.CadastroContext.Domain.Interfaces;

namespace VetBook.CadastroContext.Application.UseCases.Donos;

/* Use Case responsável por validar as credenciais de um dono no login.
 * Recebe o CPF e a senha em texto puro, busca o dono no banco pelo CPF,
 * e verifica a senha usando BCrypt (que compara o texto com o hash armazenado). */
public class ValidarCredenciaisDonoUseCase
{
    // Repositório para buscar o dono pelo CPF no banco
    private readonly IDonoRepository _repository;

    // AutoMapper para converter a entidade Dono em DonoResponse
    private readonly IMapper _mapper;

    public ValidarCredenciaisDonoUseCase(IDonoRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper     = mapper;
    }

    // Valida CPF e senha — retorna o DonoResponse se válido, ou null se inválido.
    // Retornar null (ao invés de lançar exceção) é intencional: o caller decide a mensagem de erro.
    public async Task<DonoResponse?> ExecuteAsync(string cpf, string senha, CancellationToken ct = default)
    {
        // Busca o dono pelo CPF — retorna null se não existir
        var dono = await _repository.ObterPorCpfAsync(cpf, ct);
        if (dono == null) return null;

        // Verifica se a senha digitada corresponde ao hash armazenado com BCrypt
        if (!BCrypt.Net.BCrypt.Verify(senha, dono.SenhaHash)) return null;

        // Credenciais válidas — retorna os dados do dono mapeados para o DTO
        return _mapper.Map<DonoResponse>(dono);
    }
}
