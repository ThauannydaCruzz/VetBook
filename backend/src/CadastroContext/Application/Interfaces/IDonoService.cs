using VetBook.CadastroContext.Application.DTOs;
using VetBook.CadastroContext.Domain.Interfaces;
using VetBook.SharedKernel.Common;

namespace VetBook.CadastroContext.Application.Interfaces;

// Interface de serviço de donos — fachada para todos os Use Cases de dono.
// Consumida pelos Controllers e implementada por DonoService.
public interface IDonoService
{
    // Cria um novo dono — valida CPF único e hasheia a senha
    Task<DonoResponse> CriarAsync(CreateDonoRequest request, CancellationToken ct = default);

    // Atualiza nome, email, telefone e endereço de um dono existente
    Task<DonoResponse> AtualizarAsync(Guid id, UpdateDonoRequest request, CancellationToken ct = default);

    // Remove um dono — bloqueia se ele tiver pets cadastrados
    Task RemoverAsync(Guid id, CancellationToken ct = default);

    // Busca um dono pelo ID incluindo seus pets
    Task<DonoResponse> ObterPorIdAsync(Guid id, CancellationToken ct = default);

    // Lista donos com paginação e filtros (nome, CPF, email)
    Task<PagedResult<DonoResponse>> ListarAsync(DonoFiltro filtro, CancellationToken ct = default);

    // Valida CPF e senha para autenticação — retorna null se inválido
    Task<DonoResponse?> ValidarCredenciaisAsync(string cpf, string senha, CancellationToken ct = default);
}
